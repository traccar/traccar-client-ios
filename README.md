# [Traccar Client for iOS](https://www.traccar.org/client)

[![Download on the App Store](http://www.tananaev.com/badges/app-store.svg)](https://itunes.apple.com/app/traccar-client/id843156974)

## Overview

Traccar Client is an iOS GPS tracking application. It can work with Traccar open source server software.

## Build

Project uses CocoaPods for dependencies management. To build the project you need to download dependencies:

```
pod install
```

## Configure app with an MDM (Mobile Device Management)

When deploying the application with an MDM solution, the parameters can be overloaded with a managed configuration pushed to the phone. The following table shows the keys associated with the parameters.

|Parameter name|Key|Type|
|---|---|---|
|Device identifier|device_id_preference|string|
|Server URL|server_url_preference|string|
|Location accuracy|accuracy_preference|string|
|Frequency|frequency_preference|integer|
|Distance|distance_preference|integer|
|Angle|angle_preference|integer|
|Offline buffering|buffer_preference|string|

When a parameter is configured through MDM, it is hidden in UI and cannot be changed by the user.

## Team

### Main contributors

- Anton Tananaev ([anton@traccar.org](mailto:anton@traccar.org))

### Secondary contributors

- Axel Rieben

## License

    Apache License, Version 2.0

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
