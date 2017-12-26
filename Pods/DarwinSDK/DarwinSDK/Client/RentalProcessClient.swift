//
//  RentalProcessClient.swift
//  DarwinSDK
//
//  Created by Frank Nogueiras on 10/26/16.
//  Copyright © 2016 Interval International. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

open class RentalProcessClient {
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: POST /rental/processes
    // Rental Process - Start. Requires an access token (user)
    //
    open static func start( _ accessToken:DarwinAccessToken!, process:RentalProcess!, request:RentalProcessStartRequest!, onSuccess:@escaping (_ response:RentalProcessPrepareResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/processes"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
             
                switch statusCode {
                    case 200...209:
                        let rentalProcessPrepareResponse = RentalProcessPrepareResponse(json:json)
                        // Update the RentalProcess ref
                        onSuccess(rentalProcessPrepareResponse)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /rental/processes/{processId}/prepare/continue
    // Rental Process - Continue To Checkout. Requires an access token (user)
    //
    open static func continueToCheckout( _ accessToken:DarwinAccessToken!, process:RentalProcess!, request:RentalProcessPrepareContinueToCheckoutRequest!, onSuccess:@escaping (_ response:RentalProcessRecapResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/processes/\(process!.processId)/prepare/continue"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        // TODO(Frank): Only for tests until we receive Insurance Fee from API
                        //let rentalProcessRecapResponse = addStaticInsuranceFee(RentalProcessRecapResponse(json:json))
                        let rentalProcessRecapResponse = RentalProcessRecapResponse(json:json)
                        // Update the RentalProcess ref

                        onSuccess(rentalProcessRecapResponse)

                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                    }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }

    // STATUS: Unit Test passed
    // Darwin API endpoint: DELETE /rental/processes/{processId}
    // Rental Process - Back To Choose Rental. Requires an access token (user)
    //
    open static func backToChooseRental( _ accessToken:DarwinAccessToken!, process:RentalProcess!, onSuccess:@escaping (_ response:RentalProcessEndResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/processes/\(process!.processId)"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = Dictionary<String, AnyObject>()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .delete, parameters: params,
                                                                       encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        process.currentStep = ProcessStep.End
            
                        let rentalProcessEndResponse = RentalProcessEndResponse()
                        rentalProcessEndResponse.processId = process.processId
                        rentalProcessEndResponse.step = process.currentStep
                        
                        // Update the RentalProcess ref
                        onSuccess(rentalProcessEndResponse)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test pending
    // Darwin API endpoint: PUT /rental/processes/{processId}/recap/process-promotion-code
    // Rental Process - Apply Promo Code. Requires an access token (user)
    //
    open static func applyPromoCode( _ accessToken:DarwinAccessToken!, process:RentalProcess!, request:RentalProcessRecapApplyPromoCodeRequest!, onSuccess:@escaping (_ response:RentalProcessRecapResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/processes/\(process!.processId)/recap/process-promotion-code"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
            
                switch statusCode {
                    case 200...209:
                        let rentalProcessRecapResponse = RentalProcessRecapResponse(json:json)
                        // Update the RentalProcess ref
                        onSuccess(rentalProcessRecapResponse)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /rental/processes/{processId}/recap/recalculate
    // Rental Process - Add Cart Promotion. Requires an access token (user)
    //
    open static func addCartPromotion( _ accessToken:DarwinAccessToken!, process:RentalProcess!, request:RentalProcessRecapRecalculateRequest!, onSuccess:@escaping (_ response:RentalProcessRecapResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/processes/\(process!.processId)/recap/recalculate"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        let rentalProcessRecapResponse = RentalProcessRecapResponse(json:json)
                        // Update the RentalProcess ref
                        onSuccess(rentalProcessRecapResponse)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /rental/processes/{processId}/recap/recalculate
    // Rental Process - Add Trip Protection. Requires an access token (user)
    //
    open static func addTripProtection( _ accessToken:DarwinAccessToken!, process:RentalProcess!, request:RentalProcessRecapRecalculateRequest!, onSuccess:@escaping (_ response:RentalProcessRecapResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/processes/\(process!.processId)/recap/recalculate"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        let rentalProcessRecapResponse = RentalProcessRecapResponse(json:json)
                        // Update the RentalProcess ref
                        onSuccess(rentalProcessRecapResponse)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /rental/processes/{processId}/recap/continue
    // Rental Process - Continue To Pay. Requires an access token (user)
    //
    open static func continueToPay( _ accessToken:DarwinAccessToken!, process:RentalProcess!, request:RentalProcessRecapContinueToPayRequest!, onSuccess:@escaping (_ response:RentalProcessEndResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/processes/\(process!.processId)/recap/continue"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = request.toDictionary()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        let rentalProcessEndResponse = RentalProcessEndResponse(json:json)
                        // Update the RentalProcess ref
                        onSuccess(rentalProcessEndResponse)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    // STATUS: Unit Test passed
    // Darwin API endpoint: PUT /rental/processes/{processId}/recap/back
    // Rental Process - Back To Who Is Checking. Requires an access token (user)
    //
    open static func backToWhoIsChecking( _ accessToken:DarwinAccessToken!, process:RentalProcess!, onSuccess:@escaping (_ response:RentalProcessPrepareResponse) -> Void, onError:@escaping (_ error:NSError) -> Void ) {
        let endpoint = "\(DarwinSDK.sharedInstance.getApiUri())/rental/processes/\(process!.processId)/recap/back"
        
        let headers: [String: String] = [
            "Authorization": "Bearer \(accessToken.token!)"
        ]
        
        let params = Dictionary<String, AnyObject>()
        
        DarwinSDK.logger.debug("About to try \(endpoint) with token=\(accessToken.token!) and request payload=\(params)")
        
        IntervalAlamofireManager.sharedInstance.defaultManager.request(endpoint, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers)
            //.validate(statusCode: 200...201)
            .responseJSON { response in
                let statusCode = response.response?.statusCode ?? 200
                let json = JSON(response.result.value ?? "{}")
                DarwinSDK.logger.debug("Response: \(statusCode) - \(json)")
                
                switch statusCode {
                    case 200...209:
                        let rentalProcessPrepareResponse = RentalProcessPrepareResponse(json:json)
                        // Update the RentalProcess ref
                        onSuccess(rentalProcessPrepareResponse)
                    
                    default:
                        onError(DarwinSDK.parseDarwinError(statusCode:statusCode, json:json))
                }
            }
            .responseString { response in
                DarwinSDK.logger.debug("Got \(response.response?.statusCode ?? 0) - \(response)")
        }
    }
    
    static func addStaticInsuranceFee(_ rentalProcessRecapResponse:RentalProcessRecapResponse!) -> RentalProcessRecapResponse {
        if (rentalProcessRecapResponse.view?.fees != nil && rentalProcessRecapResponse.view?.fees?.insurance == nil) {
            DarwinSDK.logger.debug("Adding a static Insurance Fee with price 99.99 and header -STATIC - Add Trip Protection-")

            let insurance = Insurance()
            insurance.price = 99.99
            insurance.insuranceOfferHTML = "<div class=\"box_rnd_3_top trip-protection-header\">\n    <h2 style=\"display:inline-block;\">\n        <strong>STATIC - Add Trip Protection</strong> <br />(Highly Recommended) \n    </h2>\n    <img src=\"https://gateway.americas.allianz-assistance.com/images/aga-usa-100x33px.png\" height=\"33\" width=\"100\" alt=\"Allianz Logo\" style=\"float:right;margin-top:10px;\"/>\n</div>\n<div class=\"box_rnd_2_mid\">\n    <div class=\"agaBlueBox\">\n        <p><strong>Peace of mind is only a tap away.</strong><br /><span style=\"font-size:.845em;\">Benefits include trip cancellation and interruption reimbursement, emergency medical and dental, travel delay protection and 24/7 emergency assistance.</span></p>\n    </div>\n    <div style=\"display: block; margin: 10px 0;\">\n        <div class=\"ui-radio\">\n            <input id='WASCInsuranceOfferOption0' type='radio' name='WASCInsuranceOfferOption' value=\"YES\" style=\"display: inline-block;\" /> \n            <label for=\"WASCInsuranceOfferOption0\" style=\"width: 90%;\" data-corners=\"true\" data-shadow=\"false\" data-iconshadow=\"true\" data-wrapperels=\"span\" data-icon=\"radio-off\" data-theme=\"a\" class=\"ui-btn ui-btn-up-a ui-btn-corner-all ui-btn-icon-left ui-radio-off\">\n                <span style=\"color:#3d89b4;\"><strong>Yes,</strong></span> add protection for $69.42. \n            </label>\n        </div> \n    </div>\n    <div>\n        \n        \n    </div>\n    <div style=\"display: block; margin: 10px 0;\">\n        <div class=\"ui-radio\">                        \n\n            <input id='WASCInsuranceOfferOption1' type='radio' name='WASCInsuranceOfferOption' value=\"NO\" style=\"display: inline-block;\" /> \n            <label for=\"WASCInsuranceOfferOption1\" style=\"width: 90%;\" data-corners=\"true\" data-shadow=\"false\" data-iconshadow=\"true\" data-wrapperels=\"span\" data-icon=\"radio-off\" data-theme=\"a\" class=\"ui-btn ui-btn-corner-all ui-btn-icon-left ui-radio-off ui-btn-up-a\">\n                <strong>No,</strong> I decline coverage. \n            </label>\n        </div> \n\n    </div> \n    \n    <p style=\"font-size:.8em;\">Terms, conditions, and exclusions <a href=\"https://gateway.americas.allianz-assistance.com/TC/ITV/OTA_IntlHotel_r.html\" rel=\"popup large\" target=\"_blank\" style=\"display: inline;\">apply</a>.<br /><span class=\"agaShowDisclaimer\">Insurance benefits are underwritten by<span id=\"agaDislaimer\"><a href=\"#agaDislaimer\" class=\"agaDislaimerShow\">... +</a> <span> BCS Insurance Company or Jefferson Insurance Company, depending on insured's state of residence.<a href=\"#\" class=\"agaDislaimerHide\"> -</a></span></span></span></p>\n</div>\n<style>\n.trip-protection {\n\tfont-size: 14px;\n\tcolor: #999;\n}\n.box_rnd_3_top.trip-protection {\n\tborder-bottom: 0px;\n}\n.trip-protection {\n\tpadding: 0px 15px;\n}\n.trip-protection-header h2 {\n\tfont-size: 1.1em;\n\tpadding: 5px 15px;\n\tcolor: #666;\n\tfont-weight: normal;\n}\n.agaBlueBox{\n    background: #3d89b4;\n    color: white !important;\n    margin:0;\n    padding:10px !important;\n    font-size: .917em;\n}\n.agaCheckIcon{\n    background: url('http://gateway.americas.allianz-assistance.com/images/icon-insurance.png') no-repeat;\n    width: 21px;\n    height: 23px;\n    float:left;\n    margin-right:5%;\n}\n.agaShowDisclaimer{\n    color:#aaa !important;\n    font-size: .8em;\n}\n.ui-radio{\n    background:white;\n    border:1px solid #aaa;\n    padding:10px;\n    height:40px;\n}\ninput[type=radio]{\n    display:none !important;\n}\nlabel:before{\n    content:\"\";\n    display:inline;\n    width:25px;\n    height:25px;\n    margin-right: 10px;\n    position: absolute;\n    left:5px;\n    top:-6px;\n    background-color: white;\n    border:1px solid #bbb;\n}\n.ui-radio label:before{\n    border-radius: 15px;\n}\nlabel{\n    display: inline-block;\n    cursor: pointer;\n    position: relative;\n    padding-left: 40px;\n    margin-right: 15px;\n    top:8px;\n    font-size: 13px;\n}\ninput[type=radio]:checked ~ label:before {\n    content: \"\\2022\";\n    color: #3d89b4;\n    font-size: 70px;\n    text-align: center;\n    line-height: 24px;\n}\n#agaDislaimer span,\n#agaDislaimer .agaDislaimerHide,\n#agaDislaimer:target .agaDislaimerShow {\n    display:none;\n    text-decoration: none;\n}\n#agaDislaimer .agaDislaimerShow,\n#agaDislaimer:target span,\n#agaDislaimer:target .agaDislaimerHide{\n    display:inline;\n    text-decoration: none;\n}  \n.agaDislaimerHide, .agaDislaimerShow{\n    color:#3d89b4;\n    font-weight: bold;\n}\n</style>"
            rentalProcessRecapResponse.view?.fees?.insurance = insurance
        }
        return rentalProcessRecapResponse
    }

}


