//
//  MockPayload.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 1/10/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation

import SwiftyJSON

open class MockPayload {
    
    open static func mockResortList() -> [Resort] {
        
        var resorts = [Resort]()
        
        let pky = Resort()
        pky.resortCode = "PKY"
        pky.resortName = "Parkway International"
        pky.address = Address();
        pky.address?.cityName = "Orlando"
        pky.address?.territoryCode = "FL"
        pky.tier = "premier"
        pky.coordinates = Coordinates(latitude: 28.3366, longitude: -81.5343)
        
        pky.images.append( Image(url:"https://www.condodirect.com/images/resd/jpg/ii_pky1.jpg",     size:ImageSize.THUMBNAIL) )
        pky.images.append( Image(url:"https://www.condodirect.com/images/resd/jpglg/ii_pky1.jpg",   size:ImageSize.LARGE) )
        pky.images.append( Image(url:"https://www.condodirect.com/images/resd/jpg1024/ii_pky1.jpg", size:ImageSize.XLARGE) )
        
        resorts.append(pky)
        
        
        let blt = Resort()
        blt.resortCode = "BLT"
        blt.resortName = "Blue Tree Resort at Lake Buena Vista"
        blt.address = Address();
        blt.address?.cityName = "Lake Buena Vista"
        blt.address?.territoryCode = "FL"
        blt.tier = "select"
        blt.coordinates = Coordinates(latitude: 28.3891, longitude: -81.503)
        
        blt.images.append( Image(url:"https://www.condodirect.com/images/resd/jpg/ii_blt1.jpg",     size:ImageSize.THUMBNAIL) )
        blt.images.append( Image(url:"https://www.condodirect.com/images/resd/jpglg/ii_blt1.jpg",   size:ImageSize.LARGE) )
        blt.images.append( Image(url:"https://www.condodirect.com/images/resd/jpg1024/ii_blt1.jpg", size:ImageSize.XLARGE) )
        
        resorts.append(blt)
        
        
        let mgv = Resort()
        mgv.resortCode = "MGV"
        mgv.resortName = "Blue Tree Resort at Lake Buena Vista"
        mgv.address = Address();
        mgv.address?.cityName = "Lake Buena Vista"
        mgv.address?.territoryCode = "FL"
        mgv.tier = "elite"
        mgv.coordinates = Coordinates(latitude: 28.396902, longitude: -81.454926)
        
        mgv.images.append( Image(url:"https://www.condodirect.com/images/resd/jpg/ii_mgv1.jpg",     size:ImageSize.THUMBNAIL) )
        mgv.images.append( Image(url:"https://www.condodirect.com/images/resd/jpglg/ii_mgv1.jpg",   size:ImageSize.LARGE) )
        mgv.images.append( Image(url:"https://www.condodirect.com/images/resd/jpg1024/ii_mgv1.jpg", size:ImageSize.XLARGE) )
        
        resorts.append(mgv)
        
        
        let cyy = Resort()
        cyy.resortCode = "CYY"
        cyy.resortName = "Calypso Cay Vacation Villas"
        cyy.address = Address();
        cyy.address?.cityName = "Lake Buena Vista"
        cyy.address?.territoryCode = "FL"
        cyy.tier = "premier"
        cyy.coordinates = Coordinates(latitude: 28.33842, longitude: -81.48179)
        
        cyy.images.append( Image(url:"https://www.condodirect.com/images/resd/jpg/ii_cyy1.jpg",     size:ImageSize.THUMBNAIL) )
        cyy.images.append( Image(url:"https://www.condodirect.com/images/resd/jpglg/ii_cyy1.jpg",   size:ImageSize.LARGE) )
        cyy.images.append( Image(url:"https://www.condodirect.com/images/resd/jpg1024/ii_cyy1.jpg", size:ImageSize.XLARGE) )
        
        resorts.append(cyy)
        
        
        return resorts
    }
    
    open static func mockAreaList() -> [Area] {
        
        var areas = [Area]()
        
        // -- Florida, Captiva & Sanibel
        
        let a365 = Area(areaCode: 365, areaName: "Florida, Captiva & Sanibel")
        a365.description = "This is the perfect place for barefoot strolls, searching for seashells, and constructing the ultimate sandcastle. Spy wading birds at a wildlife refuge, or hop on a bike and explore at your own pace  there are no stoplights to interrupt your ride."
        a365.coordinates = Coordinates(latitude: 26.475206, longitude: -82.081563)
        
        a365.images.append( Image(url:"http://www.intervalworld.com/iimedia/images/mobile/areas/365/area-tooltip-thumbnail/365.jpg",     size:ImageSize.THUMBNAIL) )
        a365.images.append( Image(url:"http://www.intervalworld.com/iimedia/images/mobile/areas/365/fullview/365.jpg", size:ImageSize.XLARGE) )
        
        areas.append(a365)
        
        
        // -- Florida Central
        
        let a331 = Area(areaCode: 331, areaName: "Florida, Central")
        a331.description = ""
        a331.coordinates = Coordinates(latitude: 27.768254, longitude: -81.558424)
        
        areas.append(a331)
        
        
        // -- Florida Cocoa Beach
        
        let a310 = Area(areaCode: 310, areaName: "Florida, Cocoa Beach")
        a310.description = "The heart of Florida's Space Coast, this seaside escape offers sand strands for every taste, from quiet coves to bustling, people-watching paradises. Not to be missed: Kennedy Space Center's rockets, launch simulations, and intergalactic artifacts."
        a310.coordinates = Coordinates(latitude: 28.414854, longitude: -80.644976)
        
        a310.images.append( Image(url:"http://www.intervalworld.com/iimedia/images/mobile/areas/310/area-tooltip-thumbnail/310.jpg",     size:ImageSize.THUMBNAIL) )
        a310.images.append( Image(url:"http://www.intervalworld.com/iimedia/images/mobile/areas/310/fullview/310.jpg", size:ImageSize.XLARGE) )
        
        areas.append(a310)
        
        
        // -- Florida Orlando
        
        let a330 = Area(areaCode: 330, areaName: "Florida, Orlando")
        a330.description = "The family-friendly Theme Park Capital of the World offers an abundance of amusement. Snap a shot with Mickey Mouse, cool off at a water park, explore iconic landmarks constructed from Legos  the possibilities are endless."
        a330.coordinates = Coordinates(latitude: 28.362495, longitude: -81.507233)
        
        a330.images.append( Image(url:"http://www.intervalworld.com/iimedia/images/mobile/areas/330/area-tooltip-thumbnail/330.jpg",     size:ImageSize.THUMBNAIL) )
        a330.images.append( Image(url:"http://www.intervalworld.com/iimedia/images/mobile/areas/330/fullview/330.jpg", size:ImageSize.XLARGE) )
        
        areas.append(a330)
        
        
        // -- Florida Upper keys
        
        let a350 = Area(areaCode: 350, areaName: "Florida, Upper Keys")
        a350.description = "Dive beneath the water's surface in Key Largo and explore a sunken naval vessel or the sole living coral barrier reef in the U.S. Hunt for tarpon, tuna, and other sport fish off Islamorada. Or just sit back, relax, and enjoy the slow-paced Keys lifestyle."
        a350.coordinates = Coordinates(latitude: 25.014336, longitude: -80.552251)
        
        a350.images.append( Image(url:"http://www.intervalworld.com/iimedia/images/mobile/areas/350/area-tooltip-thumbnail/350.jpg",     size:ImageSize.THUMBNAIL) )
        a350.images.append( Image(url:"http://www.intervalworld.com/iimedia/images/mobile/areas/350/fullview/350.jpg", size:ImageSize.XLARGE) )
        
        areas.append(a350)
        
        
        return areas
    }

}


