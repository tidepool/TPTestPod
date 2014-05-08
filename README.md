# TPServices

Provides the Objective-C APIs to connect the Backend API Services of TidePool. 

## Usage

To run the example project; clone the repo, and run `pod install` from the Project directory first. 

The API integration tests are in the TPUserServiceDemoTests project. In order to run the integration tests, the backend services need to run on your own machine, and available through the below endpoints: 

http://user-service.dev
http://game-service.dev 

You can use [pow](http://pow.cx/) to run a proxy to forward to the ports on your localhost. To do that, first install pow and make sure it is running, then do below:

    cd ~/.pow
    echo 7001 > user-service
    echo 7002 > game-service  

Now you will be able to reach those local domains. To run the services, use:

    ./int_server.sh

on the root folder of the corresponding service.(user-service and game-service) Note that, when you run that it creates, a temporary dataset for your tests. So you need to restart the user-service, everytime you run the full test suite, otherwise (at least) one of the tests will fail, as the database now contains a registered user which did not exist before.

## Requirements

## Installation


## Author

Kerem Karatal



