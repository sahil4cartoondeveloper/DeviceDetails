//
//  DeviceDataModel.swift
//  DeviceData
//
//  Created by sahil vadadoriya on 01/10/21.
//

import Foundation

public struct DeviceDataModel {
    let metric: String?
    let appID: String?
    let cpu: String?
    let ram: String?
    let batteryLife: String?
    let requestTime: String?
    let responseTime: String?
    let country: String?
    let state: String?
    let city: String?
    let mobileName: String?
    let osVersion: String?
    let uuid: String?
    let duration: String?
    let startTime: String?
    let activityName: String?
    let networkType: String?
    let appVersion: String?
    let appWifiSent: String?
    let appWifiReceived: String?
    let url: String?
    let responseCode: String?
    let type: String?
    
    public init (metric: String?, appID: String?, cpu: String?, ram: String?, batteryLife: String?, requestTime: String?, responseTime: String?, country: String?, state: String?, city: String?, mobileName: String?, osVersion: String?, uuid: String?, duration: String?, startTime: String?, activityName: String?, networkType: String?, appVersion: String?, appWifiSent: String?, appWifiReceived: String?, url: String?, responseCode: String?, type: String?) {
        
        self.metric = metric
        self.appID = appID
        self.cpu = cpu
        self.ram = ram
        self.batteryLife = batteryLife
        self.requestTime = requestTime
        self.responseTime = responseTime
        self.country = country
        self.state = state
        self.city = city
        self.mobileName = mobileName
        self.osVersion = osVersion
        self.uuid = uuid
        self.duration = duration
        self.startTime = startTime
        self.activityName = activityName
        self.networkType = networkType
        self.appVersion = appVersion
        self.appWifiSent = appWifiSent
        self.appWifiReceived = appWifiReceived
        self.url = url
        self.responseCode = responseCode
        self.type = type
    }
}
