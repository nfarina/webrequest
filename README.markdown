
SMWebRequest is a very handy lightweight HTTP request class for iOS.

It encapsulates a single HTTP request and response, and is designed to be less verbose
and simpler to use than NSURLConnection. The server response is buffered completely into memory
then passed back to event listeners as NSData. Optionally, you can specify a delegate which
can process the NSData in some way on a background thread then return something else.

More info in the blog post:
http://nfarina.com/post/3776625971/webrequest