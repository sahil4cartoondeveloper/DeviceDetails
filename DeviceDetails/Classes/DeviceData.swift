//
//  DeviceData.swift
//  DeviceDetails
//
//  Created by sahil vadadoriya on 06/10/21.
//

import Foundation
import SystemConfiguration
import CoreTelephony
import CoreLocation

public class DeviceDetails {
    
    //Variable
    var batteryLevel: Float { UIDevice.current.batteryLevel }
    var deviceDataModel: DeviceDataModel?
    var location: CLLocation?
    var country: String?
    var state: String?
    var city: String?
    
    public init() {}
    
    public func getDeviceData(successBlock: @escaping (_ DeviceData: DeviceDataModel) -> ()) {
        //Country, State and City
        LocationManager.shared.getCurrentReverseGeoCodedLocation { (location: CLLocation?, placemark: CLPlacemark?, error:NSError?) in
            guard let placemark = placemark else {
                return
            }
            print("Country :- \(placemark.country ?? "")")
            print("State :- \(placemark.administrativeArea ?? "")")
            print("City :- \(placemark.locality ?? "")")
            self.country = placemark.country
            self.state = placemark.administrativeArea
            self.city = placemark.locality
        }
        
        let secondsToDelay = 5.0
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
            self.deviceDataModel = self.deviceData()
            successBlock(self.deviceDataModel ?? DeviceDataModel(metric: "", appID: "", cpu: "", ram: "", batteryLife: "", requestTime: "", responseTime: "", country: "", state: "", city: "", mobileName: "", osVersion: "", uuid: "", duration: "", startTime: "", activityName: "", networkType: "", appVersion: "", appWifiSent: "", appWifiReceived: "", url: "", responseCode: "", type: ""))
        }
    }
    
    public func deviceData() -> DeviceDataModel {
        
        print("CPU :- \(String(describing: self.hostCPULoadInfo()))")
        print("Memory used in bytes :- \(self.report_memory())")
        print("batteryLevel :- \(batteryLevel)")
        print("Device Name :- \(UIDevice.current.name)")
        print("OS Version :- \(UIDevice.current.systemVersion)")
        print("UUID :- \(UIDevice.current.identifierForVendor?.uuidString ?? "")")
        let connectionType = getNetworkType()
        print("NetWork Type :- \(connectionType)")
        print("App Version :- \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
        
        self.deviceDataModel = DeviceDataModel(metric: "",
                                               appID: "",
                                               cpu: "\(String(describing: self.hostCPULoadInfo()))",
                                               ram: "\(self.report_memory())",
                                               batteryLife: "\(self.batteryLevel)",
                                               requestTime: "",
                                               responseTime: "",
                                               country:self.country,
                                               state: self.state,
                                               city: self.city,
                                               mobileName: "\(UIDevice.current.name)",
                                               osVersion: "\(UIDevice.current.systemVersion)",
                                               uuid: "\(UIDevice.current.identifierForVendor?.uuidString ?? "")",
                                               duration: "",
                                               startTime: "",
                                               activityName: "",
                                               networkType: connectionType,
                                               appVersion: "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")",
                                               appWifiSent: "",
                                               appWifiReceived: "",
                                               url: "",
                                               responseCode: "",
                                               type: "")
        return deviceDataModel!
    }
    
    //    func getAppID() {
    //        guard let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
    //            return
    //        }
    //
    //        let url = "https://itunes.apple.com/lookup?bundleId=\(bundleID)"
    //
    //        Alamofire.request(url).responseJSON { response in
    //            guard let value = response.result.value else { return }
    //            let json = JSON(value)  // from: import SwiftyJSON
    //
    ////            let storeVersion = json["results"][0]["version"].stringValue
    ////            print("App Version :- \(storeVersion)")
    //
    //            let storeProductID = json["results"][0]["trackId"].intValue
    //            print("App ID :- \(storeProductID)")
    //
    ////            do {
    ////            let json = try JSONSerialization.jsonObject(with: value!, options: []) as? [String : Any]
    ////
    ////            } catch {
    ////                print("erroMsg")
    ////            }
    //        }
    //    }
    
    // CPU
    private func hostCPULoadInfo() -> host_cpu_load_info? {
        let HOST_CPU_LOAD_INFO_COUNT = MemoryLayout<host_cpu_load_info>.stride/MemoryLayout<integer_t>.stride
        var size = mach_msg_type_number_t(HOST_CPU_LOAD_INFO_COUNT)
        var cpuLoadInfo = host_cpu_load_info()
        
        let result = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: HOST_CPU_LOAD_INFO_COUNT) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        if result != KERN_SUCCESS{
            print("Error  - \(#file): \(#function) - kern_result_t = \(result)")
            return nil
        }
        return cpuLoadInfo
    }
    
    //Ram
    func report_memory() -> String {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            print("Memory used in bytes :- \(taskInfo.resident_size)")
        } else {
            print("Error with task_info() :- " +
                  (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
        return "\(taskInfo.resident_size)"
    }
    
    // function of network type
    func getNetworkType() -> String {
        guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
            return "NO INTERNET"
        }
        
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability, &flags)
        
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if isReachable {
            if isWWAN {
                let networkInfo = CTTelephonyNetworkInfo()
                if #available(iOS 12.0, *) {
                    let carrierType = networkInfo.serviceCurrentRadioAccessTechnology
                    guard let carrierTypeName = carrierType?.first?.value else {
                        return "UNKNOWN"
                    }
                    switch carrierTypeName {
                    case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                        return "2G"
                    case CTRadioAccessTechnologyLTE:
                        return "4G"
                    default:
                        return "3G"
                    }
                } else {
                    // Fallback on earlier versions
                }
                return String()
            } else {
                return "WIFI"
            }
        } else {
            return "NO INTERNET"
        }
    }
}

