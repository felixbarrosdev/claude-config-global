// Data processor for customer analytics
// TODO: Clean this up before production

const fs = require('fs');

function processData(data) {
    var result = [];
    var temp = [];
    var x = 0;
    
    if(data) {
        for(var i = 0; i < data.length; i++) {
            var item = data[i];
            
            if(item.type == "customer") {
                if(item.status == "active") {
                    if(item.orders && item.orders.length > 0) {
                        var totalAmount = 0;
                        for(var j = 0; j < item.orders.length; j++) {
                            if(item.orders[j].amount) {
                                totalAmount += item.orders[j].amount;
                            }
                        }
                        if(totalAmount > 1000) {
                            var customerData = {
                                id: item.id,
                                name: item.name,
                                email: item.email,
                                total: totalAmount,
                                orderCount: item.orders.length,
                                tier: "premium"
                            };
                            
                            // Check if customer has been active recently
                            var lastOrderDate = new Date(item.orders[item.orders.length - 1].date);
                            var now = new Date();
                            var daysDiff = (now - lastOrderDate) / (1000 * 60 * 60 * 24);
                            
                            if(daysDiff < 90) {
                                customerData.active = true;
                                customerData.category = "high-value";
                            } else {
                                customerData.active = false;
                                customerData.category = "dormant";
                            }
                            
                            result.push(customerData);
                        } else {
                            var regularCustomer = {
                                id: item.id,
                                name: item.name,
                                email: item.email,
                                total: totalAmount,
                                orderCount: item.orders.length,
                                tier: "regular"
                            };
                            
                            // Check if customer has been active recently
                            var lastOrderDate = new Date(item.orders[item.orders.length - 1].date);
                            var now = new Date();
                            var daysDiff = (now - lastOrderDate) / (1000 * 60 * 60 * 24);
                            
                            if(daysDiff < 90) {
                                regularCustomer.active = true;
                                regularCustomer.category = "standard";
                            } else {
                                regularCustomer.active = false;
                                regularCustomer.category = "dormant";
                            }
                            
                            result.push(regularCustomer);
                        }
                    }
                }
            } else if(item.type == "prospect") {
                if(item.interactionCount > 5) {
                    temp.push({
                        id: item.id,
                        name: item.name,
                        email: item.email,
                        interactions: item.interactionCount,
                        source: item.source || "unknown"
                    });
                }
            }
        }
        
        // Process prospects
        for(var k = 0; k < temp.length; k++) {
            var prospect = temp[k];
            if(prospect.interactions > 10) {
                prospect.priority = "high";
            } else {
                prospect.priority = "medium";
            }
            result.push(prospect);
        }
    }
    
    return result;
}

function saveData(data, filename) {
    try {
        fs.writeFileSync(filename, JSON.stringify(data));
        console.log("Data saved successfully");
    } catch(e) {
        console.log("Error saving data: " + e.message);
    }
}

function loadData(filename) {
    try {
        var data = fs.readFileSync(filename, 'utf8');
        return JSON.parse(data);
    } catch(e) {
        console.log("Error loading data: " + e.message);
        return null;
    }
}

function analyzeCustomers(customers) {
    var stats = {
        total: customers.length,
        premium: 0,
        regular: 0,
        active: 0,
        dormant: 0
    };
    
    for(var i = 0; i < customers.length; i++) {
        var customer = customers[i];
        
        if(customer.tier == "premium") {
            stats.premium++;
        } else if(customer.tier == "regular") {
            stats.regular++;
        }
        
        if(customer.active) {
            stats.active++;
        } else {
            stats.dormant++;
        }
    }
    
    return stats;
}

// Global variables - not good practice
var config = {
    premiumThreshold: 1000,
    activeThreshold: 90,
    minInteractions: 5
};

var lastProcessedData = null;

module.exports = {
    processData: processData,
    saveData: saveData,
    loadData: loadData,
    analyzeCustomers: analyzeCustomers,
    config: config
};