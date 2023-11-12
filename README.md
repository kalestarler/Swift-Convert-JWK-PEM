# SwiftConvertJWKtoPEM

A simple script to handle the retrieval of a JWK from a public URL, and convert it to usable String PEM format.

## Installation

### Swift Package Manager
Open the following menu item in Xcode:

**File > Add Packages...**

In the  **Search or Enter Package URL**  search box enter this URL:

```
https://github.com/kalestarler/Swift-Convert-JWK-PEM
```

Then, select the dependency rule and press  **Add Package**.

## Getting Started

### Prepare your JWKS URL

Prep your JWKS URL. For example, this could be the  `jwks_uri`  retrieved from your OIDC metadata configuration link. 

For example:  `https://www.testexample.com/.well-known/jwks.json` 


## Get Public Key

The static class function `getPublicKey` takes in two parameters, a `jwksURL` and a completion block / closure.  

    SwiftConvertJWKtoPEM.getPublicKey(jwksURL: jwksURL) { result in
	    switch result {
	        case .success(let pemKey):
	        print("Retrieved public key.")
	        //Continue your own code here to use this public key PEM string
	        
        case .failure(let error):
	        print("Failed to retrieve public key: " + error.localizedDescription)
	        //Continue your own code here to handle errors
        }
    }

