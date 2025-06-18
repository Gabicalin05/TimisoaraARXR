# Timisoara AR/XR Explorer
Repo for IDMSC 2025

MindAR Github: hiukim/mind-ar-js
> Special thanks to Lucian B. for providing the 3D models used in this study via [SketchUP 3D Warehouse](https://3dwarehouse.sketchup.com/by/my) 

# Installation guide
For complete testing of the web application, all packages below are required.

- Node.js & npm
- MySQL database
- Ngrok (for HTTPS tunneling)
- (Optional) JBang & Karate for testing


## Node.js & npm

### Windows installer: 
Download installer from [nodejs.org](https://nodejs.org)


### Linux:
Install NVM:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v-.39.7/install.sh | bash
source ~/.bashrc
```

Install latest Node.js LTS version:

``` bash
nvm install --lts
nvm use --lts 
```

Check installation:

``` bash
node -v
npm -v
```

## Ngrok

### Windows:
Using [Chocolatey](https://chocolatey.org/install):

```bash
choco install ngrok
```

OR

Download the package [here](https://ngrok.com/downloads/windows?tab=download).

### Linux:
Install ngrok via Apt with the following command:
``` bash
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc \
  | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null \
  && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" \
  | sudo tee /etc/apt/sources.list.d/ngrok.list \
  && sudo apt update \
  && sudo apt install ngrok
```
Sign up to ngrok on the [official website](https://dashboard.ngrok.com/signup?ref=home-hero), then follow configuration instructions after signing up.

## Set up database
In order to have access to the models, and for the application to run correctly, please import the following into MySQL:

```database/licenta_landmarks.sql```


The tester should also create a ```.env``` file, following this template:

```bash
DB_HOST=localhost
DB_USER=yourusername
DB_PASSWORD=yourpass
DB_NAME=licenta
```
DB_HOST should stay the same.

# How to run

In TimisoaraAR directory: 

``` bash
node server.js
```

Open a new terminal and use ngrok:

```bash
ngrok http 3000
```

Once ngrok has started:

1. Copy the https link onto your phone -> open with Chrome (recommended), Firefox, or Safari;
2. Click on a pin on the map, then "Scan Building";
3. Grant all camera access requested;
4. Scan code -> get redirected to emblem scanner;
5. Scan emblem;
6. Building is rendered;
7. Press "AR" and move around the model.

# Testing

Jbang:

With Chocolatey:
```bash
choco install jbang
```

OR

```bash
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
iex "& { $(iwr https://ps.jbang.dev) } app setup"
```

Karate:
```bash 
jbang app install --name karate io.karatelabs:karate-core:1.5.0:all
```

## Running tests
Make sure the server is running:
```bash
node server.js
```

Run each test file separately:
```bash
karate filename.feature
```

Karate will provide a browser link to test results. 
