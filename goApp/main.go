package main

import (
	"crypto/ecdsa"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"

	priceFeed "github.com/dik654/MY_FI/goApp/contracts" // for demo
)

// const baseURL = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"

type ApiResponse struct {
	Data []struct {
		Symbol string `json:"symbol"`
		Quote  struct {
			USD struct {
				Price float64 `json:"price"`
			} `json:"USD"`
		} `json:"quote"`
	} `json:"data"`
}

func SaveDataToFile(data ApiResponse, filename string) {
	fileData, err := json.MarshalIndent(data, "", "  ")
	if err != nil {
		log.Fatal("Error marshalling data: ", err)
	}

	err = os.WriteFile(filename, fileData, 0644)
	if err != nil {
		log.Fatal("Error writing data to file: ", err)
	}
}

func LoadDataFromFile(filename string) ApiResponse {
	fileData, err := os.ReadFile(filename)
	if err != nil {
		log.Fatal("Error reading data from file: ", err)
	}

	var data ApiResponse
	err = json.Unmarshal(fileData, &data)
	if err != nil {
		log.Fatal("Error unmarshalling data: ", err)
	}

	return data
}

func main() {
	client, err := ethclient.Dial("https://rinkeby.infura.io")
	if err != nil {
		log.Fatal(err)
	}
	// err := godotenv.Load()
	// if err != nil {
	// 	log.Fatal("Error loading .env file")
	// }
	// var apiKey = os.Getenv("API_KEY")

	// client := &http.Client{}

	// // HTTP GET 요청 생성
	// req, err := http.NewRequest("GET", baseURL, nil)
	// if err != nil {
	// 	fmt.Println("Error creating request:", err)
	// 	return
	// }

	// fmt.Println(apiKey)
	// // 요청 헤더에 API 키 추가
	// req.Header.Add("X-CMC_PRO_API_KEY", apiKey)
	// req.Header.Add("Accept", "application/json")

	// // HTTP 요청 실행
	// resp, err := client.Do(req)
	// if err != nil {
	// 	fmt.Println("Error sending request:", err)
	// 	return
	// }
	// defer resp.Body.Close()

	// 응답 데이터 읽기
	// body, err := io.ReadAll(resp.Body)
	// if err != nil {
	// 	fmt.Println("Error reading response body:", err)
	// 	return
	// }

	// // JSON 응답 파싱
	// var apiResp ApiResponse
	// if err := json.Unmarshal(body, &apiResp); err != nil {
	// 	fmt.Println("Error parsing JSON response:", err)
	// 	return
	// }

	// // 결과 출력
	// for _, coin := range apiResp.Data {
	// 	fmt.Printf("Symbol: %s, Price: $%f\n", coin.Symbol, coin.Quote.USD.Price)
	// }

	// data := apiResp

	// // 데이터를 파일로 저장
	// SaveDataToFile(data, "coin_prices.json")

	data := LoadDataFromFile("coin_prices.json")
	for _, coin := range data.Data {
		fmt.Printf("Symbol: %s, Price: $%f\n", coin.Symbol, coin.Quote.USD.Price)
	}

	privateKey, err := crypto.HexToECDSA("fad9c8855b740a0b7ed4c221dbad0f33a83a49cad6b3fe8d5817ac83d38b6a19")
	if err != nil {
		log.Fatal(err)
	}

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("error casting public key to ECDSA")
	}

	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	fmt.Println(fromAddress)

	contractAddress := "0xYourContractAddress"

	instance, err := priceFeed.NewPriceFeed(common.HexToAddress(contractAddress), client)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("contract is loaded")
	_ = instance
}
