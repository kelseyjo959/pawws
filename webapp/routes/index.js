var express = require("express");
var router = express.Router();
var mongodb = require("mongodb");
var ObjectID = require('mongodb').ObjectID;

router.use(function(req, res, next) {
    console.log('Connection to Node Server');
    next();
});

router.get("/", function(req, res, next) {
    res.render("index");
});

router.get("/shelters", function(req, res) {
    res.render("shelters");
});

router.get("/about", function(req, res) {
    res.render("about");
});

function getLimit(screenWidth) {
    if (screenWidth < 400) {
        console.log("The screen is small, limiting to 14 pets");
        return limit = 14;
    } else if (screenWidth > 401 && screenWidth < 960) {
        console.log("the screen is medium size, limiting to 22 pets");
        return limit = 22;
    } else {
        console.log("the screen is larger, limiting to 32 pets");
        return limit = 32;
    }
};

router.get("/getPets", function(req, res) {
    console.log("GET request for pets");
    let shelter = req.headers.shelter;
    let screenWidth = req.headers.screensize;
    let petSkipCounter = req.headers.count;

    let limit = getLimit(screenWidth);
    let skipCount = parseInt(petSkipCounter);
    let mySort = { _id: -1 };

    let MongoClient = mongodb.MongoClient;
    let url = "mongodb://localhost:27017/pawws";
    MongoClient.connect(url, function(err, db) {
        if (err) {
            console.log("unable to connect to mongo server", err);
        } else {
            var pet_collection = db.collection('pets');
            if (shelter === '') {
                pet_collection.find({}).sort(mySort).skip(skipCount).limit(limit).toArray(function(err, result) {
                    if (err) {
                        res.send(err);
                    } else if (result.length) {
                        res.render("petlist", {
                            mongoPetArray: result
                        });
                    } else {
                        res.send("No more pets to be seen!");
                    }
                    db.close();
                });
            } else if (shelter === 'Stray Rescue of St Louis' || shelter === 'Adopt a Senior Pet' || shelter === 'NYC Shelter Buddy') {
                pet_collection.find({ shelter_name: shelter }).sort(mySort).skip(skipCount).limit(limit).toArray(function(err, result) {
                    if (err) {
                        res.send(err);
                    } else if (result.length) {
                        res.render("shelter_petlist", {
                            mongoPetArray: result
                        });
                    } else {
                        res.send("No more pets to be seen!");
                    }
                    db.close();
                });
            }
        }
    });


});
module.exports = router;