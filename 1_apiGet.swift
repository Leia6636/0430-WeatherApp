var location:String = "臺北市"
var weatherName: String = ""
var weatherValue: String = ""
var comfortIndex: String = ""
var maxTemp: String = ""
var minTemp: String = ""
var rainfallChance: String = ""

var LocationInformation = [(weatherName:String, weatherValue:String, comfortIndex:String, maxTemp:String, minTemp:String, rainfallChance:String)]()

func setNowLocation(){
    //設定臺北市資料顯示
}

func weatherForecast() {
    print("weatherForecast")

    let Authorization = "這裡輸入你的金鑰"
    var locationNameURL:String = ""
    
    //URL 編碼
    if let locationName = "\(location)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
        print(locationName)
        locationNameURL = locationName
    }else{
        print("URL 編碼失敗")
        locationNameURL = location
    }

    
    guard let url = URL(string: "https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001?Authorization=\(Authorization)&locationName=\(locationNameURL)") else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
        if let error = error {
            print("Error: \(error)")
            return
        }

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Error with the response, unexpected status code: \(response)")
            return
        }

        if let data = data {
            do {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                    //回傳資料處理

                    let success = json["success"] as? String

                    if let result = json["result"] as? [String: Any] {
                        if let fields = result["fields"] as? [[String: Any]] {
                        }
                    }

                    if let records = json["records"] as? [String: Any] {
                        if let datasetDescription = records["datasetDescription"] as? String {
                            print("Dataset Description: \(datasetDescription)")
                        }

                        if let location = records["location"] as? [[String: Any]] {
                            for loc in location {
                                if let locationName = loc["locationName"] as? String {
                                    print("Location: \(locationName)")
                                }
                                
                                if let weatherElements = loc["weatherElement"] as? [[String: Any]] {
                                    for element in weatherElements {
                                        if let elementName = element["elementName"] as? String {

                                            //解析出每個天氣現象到第一筆資料

                                            if elementName == "Wx" {
                                                if let time = element["time"] as? [[String: Any]], let firstTime = time.first, let parameter = firstTime["parameter"] as? [String: Any] {
                                                    weatherName = parameter["parameterName"] as! String
                                                    weatherValue = parameter["parameterValue"] as! String
                                                }
                                            } else if elementName == "CI" {
                                                if let time = element["time"] as? [[String: Any]], let firstTime = time.first, let parameter = firstTime["parameter"] as? [String: Any] {
                                                    comfortIndex = parameter["parameterName"] as! String
                                                }
                                            } else if elementName == "MaxT" {
                                                if let time = element["time"] as? [[String: Any]], let firstTime = time.first, let parameter = firstTime["parameter"] as? [String: Any] {
                                                    maxTemp = parameter["parameterName"] as! String
                                                }
                                            } else if elementName == "MinT" {
                                                if let time = element["time"] as? [[String: Any]], let firstTime = time.first, let parameter = firstTime["parameter"] as? [String: Any] {
                                                    minTemp = parameter["parameterName"] as! String
                                                }
                                            } else if elementName == "PoP" {
                                                if let time = element["time"] as? [[String: Any]], let firstTime = time.first, let parameter = firstTime["parameter"] as? [String: Any] {
                                                    rainfallChance = parameter["parameterName"] as! String
                                                }
                                            }
                                        }
                                    }

                                    //將第一筆資料加入 LocationInformation 陣列方便之後使用
                                    LocationInformation.append((weatherName: weatherName, weatherValue: weatherValue, comfortIndex: comfortIndex, maxTemp: maxTemp, minTemp: minTemp, rainfallChance: rainfallChance))

                                    //確保 UI 更新在主線進行
                                    DispatchQueue.main.async{ [self] in
                                        setNowLocation()
                                    }
                                }
                            }
                        }
                    }
                } else {
                    print("Failed to parse JSON data")
                }
            } catch {
                print("JSON Serialization Error: \(error)")
            }
        }
    }
    task.resume()
}
