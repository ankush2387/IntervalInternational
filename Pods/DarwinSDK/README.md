## DarwinSDK for iOS

The DarwinSDK for iOS makes it easy to access the Interval International Darwin REST API.  It provides the networking layer and model classes (e.g., Resort, Contact, Membership, etc.).  
The easiest way to use the SDK is to use *CocoaPods*.  Add the following to your Podfile:

```
	pod 'DarwinSDK', :git => 'https://YOUR_BITBUCKET_USERNAME@bitbucket.org/intervalintl/darwinsdk-ios.git'
```

In your application's `info.plist` file, add the following dictionary entry.  This is necessary due to the self-signed certificates used by Interval
for Internal servers.  See the Security section in the Alamofire documentation for more information.

```
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSExceptionDomains</key>
		<dict>
			<key>dev-mag.ii-apps.com</key>
			<dict>
				<key>NSExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
				<key>NSIncludesSubdomains</key>
				<true/>
			</dict>
			<key>dev2-mag.ii-apps.com</key>
			<dict>
				<key>NSExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
				<key>NSIncludesSubdomains</key>
				<true/>
			</dict>
			<key>qa-mag.ii-apps.com</key>
			<dict>
				<key>NSExceptionAllowsInsecureHTTPLoads</key>
				<true/>
				<key>NSExceptionRequiresForwardSecrecy</key>
				<false/>
				<key>NSIncludesSubdomains</key>
				<true/>
			</dict>
		</dict>
	</dict>
```

## Getting Started

Before you can access a Darwin API service, you need to have an API Key.  The Key is comprised of a Client ID and Client Secret.  You'll need to request a key
from Interval IT.  Once you have a valid API Key, you then call the DarwinSDK config method.  This typically goes in you AppDelegate's
`didFinishLaunchingWithOptions` method.  For example:

```
DarwinSDK.sharedInstance.config(.Development, client: "YOUR_CLIENT_ID", secret: "YOUR_CLIENT_SECRET")
```

The first parameter defines the environment.  Other valid options include Environment.QA and Environment.Production.  That's the simple approach.  You
can also provide logging options.  There are two: you can either pass a XCGLogger.LogLevel value, or pass an actual XCGLogger instance.  For example:

```
DarwinSDK.sharedInstance.config(.Development, client: "YOUR_CLIENT_ID", secret: "YOUR_CLIENT_SECRET", logger: myLogger)
-or-
DarwinSDK.sharedInstance.config(.Development, client: "YOUR_CLIENT_ID", secret: "YOUR_CLIENT_SECRET", logLevel: .Debug)

```


## Access Token

Once you have a valid API key and you have setup the call to config, you then begin by requesting an Access Token from the OAuth service.  
Generally speaking, there are two types of access tokens:

* Client Access Token - Used to make generic API calls, such a LookupService.countries, and other non-member related services.
* User Access Token - Used to make API calls on the behalf of a members.  Requires a User Name and Password.

To obtain an access token on behalf of a user (i.e., a User Access Token), create a Login screen specific to your application.  Once the user provices his/her user name and password, you 
can exchange those credentials for an access token.  Use that access token for all subsequent service calls.  

```
AuthProviderClient.getAccessToken("THE_USER_NAME", password: "THE_PASSWORD", 
	onSuccess:{(accessToken) in 
		UserContext.sharedInstance.accessToken = accessToken
	},
	onError:{(error) in
		NSLog(error.description)
	}
)
```

> In the example above, *UserContext* is not a Darwin class.  It's something that your application would provide, 
> and is only meant to show one of many possible implementation patterns.
> Of course, feel free to build your own method of retaining the returned contact.  

To obtain a *Client Access Token*, the method is similar, but does not require a user name or password.  Keep in mind that you will not be able to
access member data with this type of access token.


```
 AuthProviderClient.getClientAccessToken({(token) in
		UserContext.sharedInstance.accessToken = accessToken
	},
	onError:{(error) in
		NSLog(error.description)
	}
)
```


## Making Service Calls

Now that you have an access token, you can make API services calls.  Most member-based applications begin by getting user details for the currently authenticated 
user.  With Darwin, you can access member details by calling the UserService `/profiles/current` resource.  Here's an example:

```
UserClient.getProfilesCurrent(accessToken, 
	onSuccess:{(contact) in
		UserContext.sharedInstance.contact = contact
	}, 
	onError:{(error) in
		NSLog(error.description)
	}
)

```

The returned Contact object will have the user's information, including first and last name, email address, a list of membership objects, and more.


## Example Rentals Call

This example shows how to invoke one of the Rental services

```
let request = SearchDatesRequest()

request.checkInFromDate = NSDate()
request.setCheckInToDate(45) // add 45 days to from-date
        
request.areas.append( Area(areaCode:330) )
request.resorts.append( Resort(resortCode:"HCC") )
        
RentalClient.searchDates(UserContext.sharedInstance.userAccessToken, request: request,
    onSuccess: { (response) in
        // Do something amazing with the results
		
    },
    onError: {(error) in
                
    }
)


```


More to come.
