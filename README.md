##GCXUnretainedTimer
This little class is a product of some confusion and discussion at work. Apple's `NSTimer` is retaining the passed target. This will lead to a retain cycle as described [here](http://www.mikeash.com/pyblog/friday-qa-2010-04-30-dealing-with-retain-cycles.html). `CKUnretainedTimer` is a class based on `GCD` which will avoid such retain cycles by not retaining its target. 

Take a look at the demo project and you'll see further information on how to use `GCXUnretainedTimer` and a code example of the problem stated above.

##License
GCXUnretainedTimer is available under the MIT license. See the LICENSE file for more info.