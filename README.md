# Pawws

A web crawler/scraper that uses pet shelter websites to re host images and information about pets that need to be adopted. These re hosted pets are presented in a new infinite scroll format, allowing easy 'window shopping' of pets that need your love. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See Running The App for notes on how to deploy the project on a live system.

### Prerequisites

A Linux Distro with internets

Install git
```
sudo apt-get install git-all
```

### Installing

Install  MongoDB, Mongoid, Nokogiri, Node

Use the app-installer.sh bash script to install dependencies
```
sudo ./app-installer.sh
```


## Running the app

MongoDB will need to be started.

```
systemctl start mongodb

```
Pets need to be added to the database
Either run scrapers or transfer MongoDB data
Run the app
```
cd ../../../webapp/pawws
npm start
```

Open a browser and navigate to 'localhost:3000'





## Built With

* [Express](http://expressjs.com) - The web framework used


## Authors

* **Kelsey Holt** 


## Acknowledgments

* Hat tip to anyone who's code was used
* Inspiration: http://mugshot.press

