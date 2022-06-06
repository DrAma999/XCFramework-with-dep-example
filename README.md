# Distribute XCFramework with mixed implementation only and exported dependencies

We have an SDK that we would to share as XCFramework.
This SDK has some proprietary transitive dependencies
```
SDK
—>ImpOnlyA
—>ImpOnlyB
—>PublicSDK
```

ImpOnly* are imported as @_implementationOnly while PublicSDK must be exposed by SDK and is imported as @_exported

Each SDK has its own Xcode project file with Enable Libraries For Distribution at true.

We build our XCFramework from the SDK root using Carthage script `carthage build --platform iOS --no-skip-current --use-xcframeworks`

Once built we add it to a consumer app. The xcframework is added as usual inside the app project and we are able to build, launch and archive, basically “It works on my machine”.
The issue comes when we distribute the xcframework, right after trying to build it an error message is displayed
`AppDelegate.swift:9:8: Missing required modules: 'ImpOnlyA', 'ImpOnlyB', 'PublicSDK'`

I’ve also discovered that if I delete the DerivedData I can reproduce the same error, and that if I use again the script to build the SDK the error disappear.
So it seems that the consumer is looking for something in the derived data that comes form the SDK xcframework creation.
Dependencies are added to the SDK with SPM, but I tried also to add them as Xcode project and add linking manually, but the problem is till the same.

Following a lot of discussions on Swift forums, SO and Apple developers forum I’ve found this conclusion
* Xcode doesn’t generate .swiftinterface for Swift packages, even linked dynamically as [frameworks](https://kean.blog/post/xcframeworks-caveats)
* Without library evolution, an XCFramework [can’t reference symbols from a framework built from a source Swift package](https://kean.blog/post/xcframeworks-caveats)
Mostly I think that this discussion from neonacho sump pretty well the [issue](https://forums.swift.org/t/issue-with-third-party-dependencies-inside-a-xcframework-through-spm/41977/3)
“The general issue here is that the Swift compiler needs to be able to see all the modules being used at build-time, either via .swiftmodule/.swiftinterface or module maps. A single XCFramework can only contain one such module, though.”

Then he suggests some workarounds:
* You could use @_implementationOnly import for the modules from the third-party SDK if you aren't using anything from that SDK as part of your module's public interface.
* You provide the third-party SDK separately, e.g. as its own XCFramework. The important part here is that you need to make sure that it doesn't get linked statically into your other XCFramework, otherwise you will run into duplicated symbols. For packages that means making any library products dynamic. This might require some significant effort since there could be more transitive dependencies.
* You provide the additional module definitions out-of-band and make sure they get found at build-time by the compiler using search paths.

The first one is not violable for us, since we want to expose “PublicSDK”
The second neither because we would like to avoid our clients to access the dependencies
The third could be interesting because it seems that along with the xcframework we just need to add module files  but I’ve tried a lot without solving the issues, so far I’ve done:
* Create an xcframework for each dependencies to leverage Xcode create the .swiftmodule
* Tried to reference them in the consumer app using Swift Search Path -> Import path
* Tried reference them from “header search path”
* Tried reference them from “”framework search path”
Basically I don’t know which Xcode flag should I use and where to point it.



The MVP project is available here
https://www.dropbox.com/s/bxoqoaxpu2o9t6u/MVP.zip?dl=0

References:

https://kean.blog/post/xcframeworks-caveats

https://forums.swift.org/t/issue-with-third-party-dependencies-inside-a-xcframework-through-spm/41977/3

https://forums.swift.org/t/spm-dependency-problem-missing-required-module/44633/2

https://forums.swift.org/t/distribute-xcframework-of-a-swift-packages-with-local-transient-dependencies/55698/4

https://mustafa-ysf.medium.com/creating-xcframework-from-swift-package-e8af6f44501f

https://vanthanhtran245.github.io/properly-build-a-dynamic-framework-containing-a-static-one/


