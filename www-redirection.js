function handler(event) {
    var request = event.request;
    console.log(request.headers["host"]);
    if (request.headers["host"] && request.headers["host"].value.startsWith("www")) {
        var response = {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': { value: 'https://' + request.headers["host"].value.replace(/^www\./, '') + event.request.uri }
            }
        };
        return response;
    }
    return request;
}