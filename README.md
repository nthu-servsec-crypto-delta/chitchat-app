# chitchat-app

This is ChitChat Web Application.  
For API, refer to [chitchat-api](https://github.com/nthu-servsec-crypto-delta/chitchat-api)

## Install
Install required gems through bundle.

```
bundle install
```

## Setup
Set API endpoint and redis url in `config/app.yml`.  
See `config/app.example.yml` for example.

To generate new message secret, use the following command:
```bash
rake generate:msg_key
```

To generate new cookie secret for session, use the following command:  
```bash
rake generate:session_secret
```

## Run
Launch web server with following command:

```bash
rake run:dev
```

Server would listen on http://0.0.0.0:9292.