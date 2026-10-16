// Reads the companies a downstream CRM currently holds, then onboards a new company through the Apideck proxy.

import ballerina/io;
import ballerinax/apideck.proxy;

configurable string apiKey = ?;
configurable string appId = ?;
configurable string consumerId = ?;
configurable string serviceId = ?;
configurable string companiesUrl = ?;
configurable string companyName = ?;
configurable string companyWebsite = ?;
configurable boolean createCompany = false;

public function main() returns error? {
    proxy:Client apideck = check new ({authorization: apiKey, xApideckAppId: appId});

    map<string|string[]> headers = {
        "x-apideck-consumer-id": consumerId,
        "x-apideck-service-id": serviceId,
        "x-apideck-downstream-url": companiesUrl
    };

    // Step 1: List the companies the downstream CRM already holds.
    record {} existing = check apideck->proxyGet(headers);
    io:println("Existing companies response: ", existing.toJsonString());

    if !createCompany {
        io:println("createCompany is false, skipping the write.");
        return;
    }

    // Step 2: Create the new company in the downstream CRM.
    proxy:ProxyRequestBody company = {"name": companyName, "website": companyWebsite};
    record {} created = check apideck->proxyPost(company, headers);
    io:println("Created company response: ", created.toJsonString());
}
