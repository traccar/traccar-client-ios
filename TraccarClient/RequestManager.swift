//
// Copyright 2015 - 2017 Anton Tananaev (anton@traccar.org)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import SwiftSocket
import Compression
import DataCompression

func compress(data: Data) -> Data? {
    let zipped: Data! = data.zip()
    return zipped
}

public class RequestManager: NSObject {
    
    public static func sendRequest(_ url: URL?, completionHandler handler: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main, completionHandler: {(response, data, connectionError) -> Void in
            handler(data != nil)
        })
    }

}

public class IMSMonitorClient: NSObject {
    public static func sendRequest(_ url: URL, data: Data, completionHandler handler: @escaping (Bool) -> Void) {
        // Compress incoming data with zlib
        let compressed = compress(data: data)
        let client = TCPClient(address: url.host ?? "", port: Int32(url.port ?? 0))
        defer { client.close() }
        
        switch client.connect(timeout: 10) {
          case .success:
            switch client.send(data: compressed!) {
            case .success:
                let response = client.read(1024*10, timeout: 10)
                if response != nil {
                    do {
                        let responseJSON = try JSONDecoder().decode([String: Bool].self, from: Data(response!))
                        if responseJSON["success"] == true {
                            print("success")
                            handler(true)
                            return
                        } else {
                            print("error in response, no reason available")
                            handler(false)
                            return
                        }
                    } catch let error as NSError {
                        print(error)
                        handler(false)
                        return
                    }
                } else {
                    print("failed to get response")
                    handler(false)
                    return
                }
            case .failure(let error):
                print(error)
                handler(false)
                return
            }
            
          case .failure(let error):
            print(error)
            handler(false)
            return
        }
    }
}
