//
//  WeekNumber.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/12/18.
//  Copyright © 2018 Interval International. All rights reserved.
//

import Foundation

public enum WeekNumber : String {
    case FIXED_WEEK_1 = "FIXED_WEEK_1"
    case FIXED_WEEK_2 = "FIXED_WEEK_2"
    case FIXED_WEEK_3 = "FIXED_WEEK_3"
    case FIXED_WEEK_4 = "FIXED_WEEK_4"
    case FIXED_WEEK_5 = "FIXED_WEEK_5"
    case FIXED_WEEK_6 = "FIXED_WEEK_6"
    case FIXED_WEEK_7 = "FIXED_WEEK_7"
    case FIXED_WEEK_8 = "FIXED_WEEK_8"
    case FIXED_WEEK_9 = "FIXED_WEEK_9"
    case FIXED_WEEK_10 = "FIXED_WEEK_10"
    case FIXED_WEEK_11 = "FIXED_WEEK_11"
    case FIXED_WEEK_12 = "FIXED_WEEK_12"
    case FIXED_WEEK_13 = "FIXED_WEEK_13"
    case FIXED_WEEK_14 = "FIXED_WEEK_14"
    case FIXED_WEEK_15 = "FIXED_WEEK_15"
    case FIXED_WEEK_16 = "FIXED_WEEK_16"
    case FIXED_WEEK_17 = "FIXED_WEEK_17"
    case FIXED_WEEK_18 = "FIXED_WEEK_18"
    case FIXED_WEEK_19 = "FIXED_WEEK_19"
    case FIXED_WEEK_20 = "FIXED_WEEK_20"
    case FIXED_WEEK_21 = "FIXED_WEEK_21"
    case FIXED_WEEK_22 = "FIXED_WEEK_22"
    case FIXED_WEEK_23 = "FIXED_WEEK_23"
    case FIXED_WEEK_24 = "FIXED_WEEK_24"
    case FIXED_WEEK_25 = "FIXED_WEEK_25"
    case FIXED_WEEK_26 = "FIXED_WEEK_26"
    case FIXED_WEEK_27 = "FIXED_WEEK_27"
    case FIXED_WEEK_28 = "FIXED_WEEK_28"
    case FIXED_WEEK_29 = "FIXED_WEEK_29"
    case FIXED_WEEK_30 = "FIXED_WEEK_30"
    case FIXED_WEEK_31 = "FIXED_WEEK_31"
    case FIXED_WEEK_32 = "FIXED_WEEK_32"
    case FIXED_WEEK_33 = "FIXED_WEEK_33"
    case FIXED_WEEK_34 = "FIXED_WEEK_34"
    case FIXED_WEEK_35 = "FIXED_WEEK_35"
    case FIXED_WEEK_36 = "FIXED_WEEK_36"
    case FIXED_WEEK_37 = "FIXED_WEEK_37"
    case FIXED_WEEK_38 = "FIXED_WEEK_38"
    case FIXED_WEEK_39 = "FIXED_WEEK_39"
    case FIXED_WEEK_40 = "FIXED_WEEK_40"
    case FIXED_WEEK_41 = "FIXED_WEEK_41"
    case FIXED_WEEK_42 = "FIXED_WEEK_42"
    case FIXED_WEEK_43 = "FIXED_WEEK_43"
    case FIXED_WEEK_44 = "FIXED_WEEK_44"
    case FIXED_WEEK_45 = "FIXED_WEEK_45"
    case FIXED_WEEK_46 = "FIXED_WEEK_46"
    case FIXED_WEEK_47 = "FIXED_WEEK_47"
    case FIXED_WEEK_48 = "FIXED_WEEK_48"
    case FIXED_WEEK_49 = "FIXED_WEEK_49"
    case FIXED_WEEK_50 = "FIXED_WEEK_50"
    case FIXED_WEEK_51 = "FIXED_WEEK_51"
    case FIXED_WEEK_52 = "FIXED_WEEK_52"
    case FIXED_WEEK_53 = "FIXED_WEEK_53"
    case FLOAT_WEEK = "FLOAT_WEEK"
    case POINTS_WEEK = "POINTS_WEEK"
    case MANUAL_REPLACEMENT_WEEK = "MANUAL_REPLACEMENT_WEEK"
    case GETAWAYS_WEEK = "GETAWAYS_WEEK"
    case ACCOMMODATION_CERTIFICATE_WEEK = "ACCOMMODATION_CERTIFICATE_WEEK"
    case VIP_WEEK = "VIP_WEEK"
    case XYZ_RELINQUISHMENT_WEEK = "XYZ_RELINQUISHMENT_WEEK"
    case EMPLOYEE_WAITLIST = "EMPLOYEE_WAITLIST"
    case SHORT_STAY_CREDITS_WEEK = "SHORT_STAY_CREDITS_WEEK"
    case RESORT_INFO_PROMPT_WEEK = "RESORT_INFO_PROMPT_WEEK"
    case UNKNOWN = "UNKNOWN"

    var name: String {
        return self.rawValue
    }
    
    // Helper methods for UI
    public func isThis(name : String) -> Bool {
        return self.name == name
    }
    
    public func isPointWeek() -> Bool {
        return isThis(name: "POINTS_WEEK")
    }
    
    public func isFloatWeek() -> Bool {
        return isThis(name: "FLOAT_WEEK")
    }
    
    public func isFixedWeek() -> Bool {
        return name.contains("FIXED_WEEK_")
    }
    
    public func getFixedWeekNumber() -> String {
        return isFixedWeek() ? name.replacingOccurrences(of: "FIXED_WEEK_", with: "") : ""
    }
    
    public static func fromName(name : String) -> WeekNumber {
        if WeekNumber.FIXED_WEEK_1.name == name {
            return WeekNumber.FIXED_WEEK_1
        } else if WeekNumber.FIXED_WEEK_2.name == name {
            return WeekNumber.FIXED_WEEK_2
        } else if WeekNumber.FIXED_WEEK_3.name == name {
            return WeekNumber.FIXED_WEEK_3
        } else if WeekNumber.FIXED_WEEK_4.name == name {
            return WeekNumber.FIXED_WEEK_4
        } else if WeekNumber.FIXED_WEEK_5.name == name {
            return WeekNumber.FIXED_WEEK_5
        } else if WeekNumber.FIXED_WEEK_6.name == name {
            return WeekNumber.FIXED_WEEK_6
        } else if WeekNumber.FIXED_WEEK_7.name == name {
            return WeekNumber.FIXED_WEEK_7
        } else if WeekNumber.FIXED_WEEK_8.name == name {
            return WeekNumber.FIXED_WEEK_8
        } else if WeekNumber.FIXED_WEEK_9.name == name {
            return WeekNumber.FIXED_WEEK_9
        } else if WeekNumber.FIXED_WEEK_10.name == name {
            return WeekNumber.FIXED_WEEK_10
        } else if WeekNumber.FIXED_WEEK_11.name == name {
            return WeekNumber.FIXED_WEEK_11
        } else if WeekNumber.FIXED_WEEK_12.name == name {
            return WeekNumber.FIXED_WEEK_12
        } else if WeekNumber.FIXED_WEEK_13.name == name {
            return WeekNumber.FIXED_WEEK_13
        } else if WeekNumber.FIXED_WEEK_14.name == name {
            return WeekNumber.FIXED_WEEK_14
        } else if WeekNumber.FIXED_WEEK_15.name == name {
            return WeekNumber.FIXED_WEEK_15
        } else if WeekNumber.FIXED_WEEK_16.name == name {
            return WeekNumber.FIXED_WEEK_16
        } else if WeekNumber.FIXED_WEEK_17.name == name {
            return WeekNumber.FIXED_WEEK_17
        } else if WeekNumber.FIXED_WEEK_18.name == name {
            return WeekNumber.FIXED_WEEK_18
        } else if WeekNumber.FIXED_WEEK_19.name == name {
            return WeekNumber.FIXED_WEEK_19
        } else if WeekNumber.FIXED_WEEK_20.name == name {
            return WeekNumber.FIXED_WEEK_20
        } else if WeekNumber.FIXED_WEEK_21.name == name {
            return WeekNumber.FIXED_WEEK_21
        } else if WeekNumber.FIXED_WEEK_22.name == name {
            return WeekNumber.FIXED_WEEK_22
        } else if WeekNumber.FIXED_WEEK_23.name == name {
            return WeekNumber.FIXED_WEEK_23
        } else if WeekNumber.FIXED_WEEK_24.name == name {
            return WeekNumber.FIXED_WEEK_24
        } else if WeekNumber.FIXED_WEEK_25.name == name {
            return WeekNumber.FIXED_WEEK_25
        }else if WeekNumber.FIXED_WEEK_26.name == name {
            return WeekNumber.FIXED_WEEK_26
        } else if WeekNumber.FIXED_WEEK_27.name == name {
            return WeekNumber.FIXED_WEEK_27
        } else if WeekNumber.FIXED_WEEK_28.name == name {
            return WeekNumber.FIXED_WEEK_28
        } else if WeekNumber.FIXED_WEEK_29.name == name {
            return WeekNumber.FIXED_WEEK_29
        } else if WeekNumber.FIXED_WEEK_30.name == name {
            return WeekNumber.FIXED_WEEK_30
        } else if WeekNumber.FIXED_WEEK_31.name == name {
            return WeekNumber.FIXED_WEEK_31
        } else if WeekNumber.FIXED_WEEK_32.name == name {
            return WeekNumber.FIXED_WEEK_32
        } else if WeekNumber.FIXED_WEEK_33.name == name {
            return WeekNumber.FIXED_WEEK_33
        } else if WeekNumber.FIXED_WEEK_34.name == name {
            return WeekNumber.FIXED_WEEK_34
        } else if WeekNumber.FIXED_WEEK_35.name == name {
            return WeekNumber.FIXED_WEEK_35
        } else if WeekNumber.FIXED_WEEK_36.name == name {
            return WeekNumber.FIXED_WEEK_36
        } else if WeekNumber.FIXED_WEEK_37.name == name {
            return WeekNumber.FIXED_WEEK_37
        } else if WeekNumber.FIXED_WEEK_38.name == name {
            return WeekNumber.FIXED_WEEK_38
        } else if WeekNumber.FIXED_WEEK_39.name == name {
            return WeekNumber.FIXED_WEEK_39
        } else if WeekNumber.FIXED_WEEK_40.name == name {
            return WeekNumber.FIXED_WEEK_40
        } else if WeekNumber.FIXED_WEEK_41.name == name {
            return WeekNumber.FIXED_WEEK_41
        } else if WeekNumber.FIXED_WEEK_42.name == name {
            return WeekNumber.FIXED_WEEK_42
        } else if WeekNumber.FIXED_WEEK_43.name == name {
            return WeekNumber.FIXED_WEEK_43
        } else if WeekNumber.FIXED_WEEK_44.name == name {
            return WeekNumber.FIXED_WEEK_44
        } else if WeekNumber.FIXED_WEEK_45.name == name {
            return WeekNumber.FIXED_WEEK_45
        } else if WeekNumber.FIXED_WEEK_46.name == name {
            return WeekNumber.FIXED_WEEK_46
        } else if WeekNumber.FIXED_WEEK_47.name == name {
            return WeekNumber.FIXED_WEEK_47
        } else if WeekNumber.FIXED_WEEK_48.name == name {
            return WeekNumber.FIXED_WEEK_48
        } else if WeekNumber.FIXED_WEEK_49.name == name {
            return WeekNumber.FIXED_WEEK_49
        } else if WeekNumber.FIXED_WEEK_50.name == name {
            return WeekNumber.FIXED_WEEK_50
        } else if WeekNumber.FIXED_WEEK_51.name == name {
            return WeekNumber.FIXED_WEEK_51
        } else if WeekNumber.FIXED_WEEK_52.name == name {
            return WeekNumber.FIXED_WEEK_52
        } else if WeekNumber.FIXED_WEEK_53.name == name {
            return WeekNumber.FIXED_WEEK_53
        } else if WeekNumber.FLOAT_WEEK.name == name {
            return WeekNumber.FLOAT_WEEK
        } else if WeekNumber.POINTS_WEEK.name == name {
            return WeekNumber.POINTS_WEEK
        } else if WeekNumber.MANUAL_REPLACEMENT_WEEK.name == name {
            return WeekNumber.MANUAL_REPLACEMENT_WEEK
        } else if WeekNumber.GETAWAYS_WEEK.name == name {
            return WeekNumber.GETAWAYS_WEEK
        } else if WeekNumber.ACCOMMODATION_CERTIFICATE_WEEK.name == name {
            return WeekNumber.ACCOMMODATION_CERTIFICATE_WEEK
        } else if WeekNumber.VIP_WEEK.name == name {
            return WeekNumber.VIP_WEEK
        } else if WeekNumber.XYZ_RELINQUISHMENT_WEEK.name == name {
            return WeekNumber.XYZ_RELINQUISHMENT_WEEK
        } else if WeekNumber.EMPLOYEE_WAITLIST.name == name {
            return WeekNumber.EMPLOYEE_WAITLIST
        } else if WeekNumber.SHORT_STAY_CREDITS_WEEK.name == name {
            return WeekNumber.SHORT_STAY_CREDITS_WEEK
        } else if WeekNumber.RESORT_INFO_PROMPT_WEEK.name == name {
            return WeekNumber.RESORT_INFO_PROMPT_WEEK
        } else {
            return WeekNumber.UNKNOWN
        }
    }
}


