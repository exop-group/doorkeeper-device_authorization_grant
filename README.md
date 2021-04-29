# Doorkeeper::DeviceAuthorizationGrant

OAuth 2.0 device authorization grant extension for Doorkeeper. 

This library implements the OAuth 2.0 device authorization grant 
([RFC 8628](https://tools.ietf.org/html/rfc8628)) for 
[Ruby on Rails](https://rubyonrails.org/) applications on top of the
[Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper) OAuth 2.0 framework.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'doorkeeper-device_authorization_grant'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install doorkeeper-device_authorization_grant
```

Run the installation generator to update routes and create a dedicated initializer:

```bash
$ rails generate doorkeeper:device_authorization_grant:install
```

Generate a migration for Active Record (other ORMs are currently not supported):

```bash
$ rails doorkeeper_device_authorization_grant_engine:install:migrations
```

## Configuration

### Doorkeeper configuration

In your Doorkeeper initializer (usually `config/initializers/doorkeeper.rb`), enable
the new grant flow extension, adding to the `grant_flows` option the `device_code`
string. For example:

```ruby
  # config/initializers/doorkeeper.rb
  
  Doorkeeper.configure do
    # ... 
  
    grant_flows [
      'device_code',
 
      # together with all the other grant flows you already enabled, for example:
      'authorization_code',
      'client_credentials'
      # ...
    ]

    # ...
  end
```

### Device Authorization Grant configuration

The gem's installation scripts automatically creates a new initializer file:
`config/initializers/doorkeeper_device_authorization_grant.rb`. Here you can
adjust the configuration parameters according to your needs.

### Routes

The gem's installation scripts automatically modify your `config/routes.rb`
file, adding the default routes to the controllers described above. The
routes file should then look like this:

```ruby
Rails.application.routes.draw do
  use_doorkeeper_device_authorization_grant
  # your routes ...
end
```

This is enough to add to your app the following default routes:

```
                               Prefix  Verb  URI                      Controller#Action
            oauth_device_codes_create  POST  /oauth/authorize_device  doorkeeper/device_authorization_grant/device_codes#create
    oauth_device_authorizations_index  GET   /oauth/device            doorkeeper/device_authorization_grant/device_authorizations#index
oauth_device_authorizations_authorize  POST  /oauth/device            doorkeeper/device_authorization_grant/device_authorizations#authorize
```

The routing method `use_doorkeeper_device_authorization_grant` allows extra customization,
just like `use_doorkeeper` (see [Doorkeeper Wiki - Customizing routes](https://github.com/doorkeeper-gem/doorkeeper/wiki/Customizing-routes)).

This Gem defines two Rails controllers:

- `DeviceCodesController` serves Device Authorization requests, as described
  by [RFC 8628](https://tools.ietf.org/html/rfc8628), sections 3.1
  and 3.2. 
- `DeviceAuthorizationsController` provides a bare-bones implementation of a
  verification web page which allows an authenticated resource-owner to
  authorize a device, by providing an end-user code.

You can change the controllers to your **custom controllers** with the `controller` option:

```ruby
Rails.application.routes.draw do
  use_doorkeeper_device_authorization_grant do
    # it accepts :device_authorizations and :device_codes
    controller device_authorizations: 'custom_device_authorizations'
  end
end
```

Be sure to use the same superclasses of the original controllers (or something compatible).

You can set **custom aliases** with `as`:

```ruby
Rails.application.routes.draw do
  use_doorkeeper_device_authorization_grant do
    # it accepts :device_authorizations and :device_codes
    as device_codes: :custom_device
  end
end
```

You can **skip routes** with `skip_controllers`:

```ruby
Rails.application.routes.draw do
  use_doorkeeper_device_authorization_grant do
    # it accepts :device_authorizations and :device_codes
    skip_controllers :device_authorizations
  end
end
```

The default scope is `oauth`. You can provide a **custom scope** like this:

```ruby
Rails.application.routes.draw do
  use_doorkeeper_device_authorization_grant scope: 'oauth2'
end
```

## Usage

The following sections show the typical steps of a device authorization flow.
Default configuration and routes are assumed.

### Device Authorization Request

Reference: [RFC 8628, section 3.1 - Device Authorization Request](https://tools.ietf.org/html/rfc8628#section-3.1).

First of all, a *Device Client* can perform a *Device Authorization Request* to
the *Authorization Server* (your Rails application, with Doorkeeper and this
gem extension) like this:

```http request
POST /oauth/authorize_device HTTP/1.1
Content-Type: application/x-www-form-urlencoded

client_id=1406020730&scope=example_scope
```

### Device Authorization Response

Reference: [RFC 8628, section 3.2 - Device Authorization Response](https://tools.ietf.org/html/rfc8628#section-3.2).

The *Authorization Server* responds with a *Device Authorization Response*:

```
HTTP/1.1 200 OK
Content-Type: application/json

{
    "device_code": "GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS",
    "user_code": "0A44L90H",
    "verification_uri": "https://example.com/oauth/device",
    "verification_uri_complete": "https://example.com/oauth/device?user_code=0A44L90H",
    "expires_in": 300,
    "interval": 5
}
``` 

### User interaction

Reference: [RFC 8628, section 3.3 - User Interaction](https://tools.ietf.org/html/rfc8628#section-3.3).

The *Device Client* can now display to the end user the `user_code` and the
`verification_uri` (or somehow make use of `verification_uri_complete`, in special cases).
 
The user should visit  URI in a user agent on a secondary device (for example, in a browser
on their mobile phone) and enter the user code.

During the user interaction, the device continuously polls the token endpoint with the
`device_code`, as detailed in the next section, until the user completes the interaction,
the code expires, or another error occurs.

The default Rails route provided by this Gem, `/oauth/device`, allows an authenticated
request owner (for example, a user) to manually verify the user code.

### Device Access Token Request / polling

Reference: [RFC 8628, section 3.4 - Device Access Token Request](https://tools.ietf.org/html/rfc8628#section-3.4).

After displaying instructions to the user, the *Device Client* should create a
*Device Access Token Request* and send it to the token endpoint (provided
by Dorkeeper), for example:

```http request
POST /oauth/token HTTP/1.1
Content-Type: application/x-www-form-urlencoded

grant_type=urn:ietf:params:oauth:grant-type:device_code
&device_code=GmRhmhcxhwAzkoEqiMEg_DnyEysNkuNhszIySk9eS
&client_id=1406020730
```

The response to this request is defined in the next section. It is expected for
the *Device Client* to try the access token request repeatedly in a polling
fashion, based on the error code in the response. The polling time interval
was possibly included in the *Device Authorization Response*, but it is
optional; if no value was provided, the client MUST use 5 seconds as the default.

### Device Access Token Response

Reference: [RFC 8628, section 3.5 - Device Access Token Response](https://tools.ietf.org/html/rfc8628#section-3.5).

Please refer to the RFC document for exhaustive documentation. Here we show just
some possible responses.

While the authorization request is still pending, and the device-code token is
not expired, the response contains an `authorization_pending` error:

```
HTTP/1.1 400 Bad Request
Content-Type: application/json

{ "error": "authorization_pending", "error_description": "..." }
```

The client should simply continue with further polling requests.

If the client requests are too close in time, a `slow_down` error is returned:

```
HTTP/1.1 400 Bad Request
Content-Type: application/json

{ "error": "slow_down", "error_description": "..." }
```

The client can still continue with polling requests, but the polling time interval
MUST be increased by 5 seconds for all subsequent requests.

If the `device_code` has expired, the response contains the `expired_token` error:

```
HTTP/1.1 400 Bad Request
Content-Type: application/json

{ "error": "expired_token", "error_description": "..." }
```

The client should stop polling, and may commence a new device authorization
request (possibly upon waiting for further user interaction).

Once the user has successfully authorized the device, a successful response will
be eventually returned. This is a standard OAuth 2.0 response, described in
[Section 5.1 of [RFC6749]](https://tools.ietf.org/html/rfc6749#section-5.1). Here
is a typical bearer token response:

```
HTTP/1.1 200 OK
Content-Type: application/json

{
    "access_token": "FkPeBMF8Ab0zkYj6vQLZCxZ5OP0Hrd7ST3RS99x7nRM",
    "token_type": "Bearer",
    "expires_in": 7200,
    "scope": "read",
    "created_at": 1593096829
}
```

The device authentication flow is now complete, and the token data can be used to
authenticate requests against the authorization and/or resource server.

## Example Application

Here you can find an example Rails application which uses this gem,
together with a little HTML/JS client to try out the device flow:

[https://github.com/exop-group/doorkeeper-device-flow-example](https://github.com/exop-group/doorkeeper-device-flow-example)

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
