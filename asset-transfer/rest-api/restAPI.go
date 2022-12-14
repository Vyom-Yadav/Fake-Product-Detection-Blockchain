package main

import (
	"crypto/x509"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
	"github.com/skip2/go-qrcode"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

type Product struct {
	ProductID        string `json:"ProductID"`
	ProductType      string `json:"ProductType"`
	Owner            Owner  `json:"Owner"`
	WithManufacturer bool   `json:"WithManufacturer"`
	WithRetailer     bool   `json:"WithRetailer"`
	WithConsumer     bool   `json:"WithConsumer"`
}

type Owner struct {
	OwnerName    string `json:"OwnerName"`
	OwnerAddress string `json:"OwnerAddress"`
}

const (
	mspID         = "CustomerMSP"
	cryptoPath    = "../../organizations/peerOrganizations/customer.com"
	certPath      = cryptoPath + "/users/User1@customer.com/msp/signcerts/cert.pem"
	keyPath       = cryptoPath + "/users/User1@customer.com/msp/keystore/"
	tlsCertPath   = cryptoPath + "/peers/peer0.customer.com/tls/ca.crt"
	peerEndpoint  = "localhost:11051"
	gatewayPeer   = "peer0.customer.com"
	channelName   = "supply-chain"
	chaincodeName = "product-chaincode"
)

func main() {
	// The gRPC client connection should be shared by all Gateway connections to this endpoint
	clientConnection := newGrpcConnection()
	defer clientConnection.Close()

	id := newIdentity()
	sign := newSign()

	// Create a Gateway connection for a specific client identity
	gw, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(clientConnection),
		// Default timeouts for different gRPC calls
		client.WithEvaluateTimeout(5*time.Second),
		client.WithEndorseTimeout(15*time.Second),
		client.WithSubmitTimeout(5*time.Second),
		client.WithCommitStatusTimeout(1*time.Minute),
	)
	if err != nil {
		panic(err)
	}
	defer gw.Close()

	network := gw.GetNetwork(channelName)
	contract := network.GetContract(chaincodeName)
	createQRCodes(os.Args[1], contract)

	router := gin.Default()
	router.GET("/products/:id", func(context *gin.Context) {
		id := context.Param("id")
		asset, err := readAssetByID(contract, id)

		if err == nil {
			context.IndentedJSON(http.StatusOK, asset)
			return
		}

		context.IndentedJSON(http.StatusNotFound, gin.H{"message": "product not found"})
	})

	err = router.Run("localhost:8081")
	if err != nil {
		log.Fatal(err)
	}
}

// newGrpcConnection creates a gRPC connection to the Gateway server.
func newGrpcConnection() *grpc.ClientConn {
	certificate, err := loadCertificate(tlsCertPath)
	if err != nil {
		panic(err)
	}

	certPool := x509.NewCertPool()
	certPool.AddCert(certificate)
	transportCredentials := credentials.NewClientTLSFromCert(certPool, gatewayPeer)

	connection, err := grpc.Dial(peerEndpoint, grpc.WithTransportCredentials(transportCredentials))
	if err != nil {
		panic(fmt.Errorf("failed to create gRPC connection: %w", err))
	}

	return connection
}

// newIdentity creates a client identity for this Gateway connection using an X.509 certificate.
func newIdentity() *identity.X509Identity {
	certificate, err := loadCertificate(certPath)
	if err != nil {
		panic(err)
	}

	id, err := identity.NewX509Identity(mspID, certificate)
	if err != nil {
		panic(err)
	}

	return id
}

func loadCertificate(filename string) (*x509.Certificate, error) {
	certificatePEM, err := os.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read certificate file: %w", err)
	}
	return identity.CertificateFromPEM(certificatePEM)
}

// newSign creates a function that generates a digital signature from a message digest using a private key.
func newSign() identity.Sign {
	files, err := os.ReadDir(keyPath)
	if err != nil {
		panic(fmt.Errorf("failed to read private key directory: %w", err))
	}
	privateKeyPEM, err := os.ReadFile(path.Join(keyPath, files[0].Name()))

	if err != nil {
		panic(fmt.Errorf("failed to read private key file: %w", err))
	}

	privateKey, err := identity.PrivateKeyFromPEM(privateKeyPEM)
	if err != nil {
		panic(err)
	}

	sign, err := identity.NewPrivateKeySign(privateKey)
	if err != nil {
		panic(err)
	}

	return sign
}

// Evaluate a transaction by assetID to query ledger state.
func readAssetByID(contract *client.Contract, id string) (Product, error) {
	fmt.Printf("Evaluate Transaction: ReadAsset, function returns asset attributes\n")

	evaluateResult, err := contract.EvaluateTransaction("ReadAsset", id)
	var product Product
	if err != nil {
		return product, err
	}
	err = json.Unmarshal(evaluateResult, &product)
	if err != nil {
		return product, err
	}
	return product, nil
}

// Evaluate a transaction to query ledger state.
func getAllAssets(contract *client.Contract) ([]Product, error) {
	fmt.Println("Evaluate Transaction: GetAllAssets, function returns all the current assets on the ledger")

	evaluateResult, err := contract.EvaluateTransaction("GetAllAssets")
	var products []Product
	if err != nil {
		return products, nil
	}
	err = json.Unmarshal(evaluateResult, &products)
	if err != nil {
		return products, err
	}
	return products, nil
}

func createQRCodes(url string, contract *client.Contract) {
	products, err := getAllAssets(contract)
	if err != nil {
		panic(err)
	}
	for index, product := range products {
		// create a file wit relative path
		file, err := os.Create(fmt.Sprintf("../../qr-codes/qr-%d.png", index))
		err = qrcode.WriteFile(url+"/products/"+product.ProductID, qrcode.Highest, 256, file.Name())
		if err != nil {
			panic(err)
		}
	}
}
