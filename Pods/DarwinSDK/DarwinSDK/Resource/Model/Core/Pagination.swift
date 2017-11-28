//
//  Pagination.swift
//  DarwinSDK
//
//  Created by Raf Fiol on 12/1/15.
//  Copyright © 2015 Interval International. All rights reserved.
//

import Foundation
import SwiftyJSON

open class Pagination {
    
	open var currentPage : Int = 0
	open var totalNumberOfPages : Int = 0
	open var itemsPerPage : Int = 0
	open var startRecordOnPage : Int = 0
	open var endRecordOnPage : Int = 0
	open var totalEntries : Int = 0
	
	public init() {
	}
	
	// This init method will intialize a resort object
	// given a detailed JSON object
	//
	public init(json:JSON) {
		// Sadly, all int values in the JSON response are
		// quoted, making them strings.  Must convert to int first.
		
		self.currentPage = Int(json["currentPage"].string ?? "0") ?? 0
		self.totalNumberOfPages = Int(json["totalNumberOfPages"].string ?? "0") ?? 0
		self.itemsPerPage = Int(json["itemsPerPage"].string ?? "0") ?? 0
		self.startRecordOnPage = Int(json["startRecordOnPage"].string ?? "0") ?? 0
		self.endRecordOnPage = Int(json["endRecordOnPage"].string ?? "0") ?? 0
		self.totalEntries = Int(json["totalEntries"].string ?? "0") ?? 0
	}
	
}
