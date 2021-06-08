# The Inter-NMI Experiment: An experimental blockchain network among National Metrology Institutes

This repository contains the implementation of **The Inter NMI Experiment**, developed in cooperation between the Physikalisch-Technische Bundesanstalt (PTB) and the National Institute of Metrology, Quality, and Technology (Inmetro), that are respectively the National Metrology Institutes in Germany and Brazil.

Research team:
* *Mahbuba Moni. (mahbuba.moni@ptb.de)*
* *[Wilson S. Melo Jr.](https://www.researchgate.net/profile/Wilson-Melo-Junior) (wsjunior@inmetro.gov.br)*

Coordination:
* *Daniel Peters (peters@ptb.de)*
* *Wladmir Chapetta (wachapetta@inmetro.gov.br)*

*Revised on March 16th, 2021.*

## What the Inter-NMI Experiment is

The Inter-NMI Experiment is an experimental blockchain network formed by National Metrology Institutes around the world. It integrates servers provided by different NMIs and enables the implementation and test of smart contract-based applications related to metrology and conformity assessment. Research teams in each NMI can create their smart contracts and test them with the support from other NMIs.

We adopt [Hyperledger Fabric 1.4 LTS](https://hyperledger-fabric.readthedocs.io/en/release-1.4/) as our blockchain platform. We configure a globally distributed blockchain network that supports the execution of Golang chaincodes.

We describe in the next sections the main aspects related to the Inter-NMI blockchain network customizing, how to instantiate the network, how to deploy a chaincode, and how to use a simple Python client to invoke it.

We also invite the reader to check out our previous publications related to this project. They are listed below:


* [Moni, M., Melo, W., Peters, D., & Machado, R. (2021). When Measurements Meet Blockchain: On Behalf of an Inter-NMI Network. Sensors, 21(5), 1564.](https://doi.org/10.3390/s21051564)

* [Melo Jr, W. S., Tarelho, L. V., Rodrigues Filho, B. A., Bessani, A. N., & Carmo, L. F. (2021). Field surveillance of fuel dispensers using IoT-based metering and blockchains. Journal of Network and Computer Applications, 175, 102914.](https://doi.org/10.1016/j.jnca.2020.102914)

* [Melo, W., Machado, R. C., Peters, D., & Moni, M. (2020). Public-Key Infrastructure for Smart Meters using Blockchains. In 2020 IEEE International Workshop on Metrology for Industry 4.0 & IoT (pp. 429-434). IEEE.](https://doi.org/10.1109/MetroInd4.0IoT48571.2020.9138246)

* [Yurchenko, A., Moni, M., Peters, D., Nordholz, J., & Thiel, F. (2020). Security for Distributed Smart Meter : Blockchain-based Approach , Ensuring Privacy by Functional Encryption. In Proceedings of the 10th International Conference on Cloud Computing and Services Science - CLOSER (pp. 292–301).](https://doi.org/10.5220/0009377702920301)

* [Peters, D., Yurchenko, A., Melo, W., Shirono, K., Usuda, T., Seifert, J. P., & Thiel, F. (2020). IT Security for Measuring Instruments: Confidential Checking of Software Functionality. In Future of Information and Communication Conference (pp. 701-720). Springer, Cham.](https://doi.org/10.1007/978-3-030-39445-5_51)

* [Melo Jr., W. S., Bessani, A., Neves, N., Santin, A. O., & Carmo, L. F. R. C. (2019). Using Blockchains to Implement Distributed Measuring Systems. IEEE Transactions on Instrumentation and Measurement, 68(5), 1503–1512.](https://doi.org/10.1109/TIM.2019.2898013)

* [Peters, D., Wetzlich, J., Thiel, F., & Seifert, J. (2018). Blockchain Applications for Legal Metrology. In IEEE International Instrumentation and Measurement Technology Conference (p. 6). Houston, Texas, USA.](https://doi.org/10.1109/I2MTC.2018.8409668)


## The customized blockchain network

We provide a flexible Fabric blockchain network configuration, initially with three organizations. The first one is the **Orderer** organization, which encapsulates the Inter-NMI network orderer service. So far, we are using the *solo orderer* provided for Fabric. However, we intend to replace it with a complete consensus service as soon as possible. The second and third organizations are **PTB** (under the virtual domain *ptb.de*) and **Inmetro** (under de virtual domain *inmetro.br*). 

PTB and Inmetro represent the NMIs that integrates the Inter-NMI network at the moment. In the Inter-NMI initial configuration, each organization provides two peers (peer0 and peer1). The configuration also considers that peer0 in both organizations are endorser peers, and peer1 are only committer peers. However, the configuration is flexible, and the network administrator in each organization can easily change it to include more peers and also to change peers' roles. We also use [Couchdb](https://hyperledger-fabric.readthedocs.io/en/release-1.4/couchdb_tutorial.html) containers to improve the performance of storing the ledger state on each peer.

All the configuration files related to the blockchain network are in the base folder. The main files are:

* [configtx.yaml](configtx.yaml): basic network profile of Inter-NMI blockchain network.
* [crypto-config-nmi.yaml](crypto-config-nmi.yaml): (Membership Service Provider) configuration. We generate all the digital certificates from it.
* [peer-ordererer.yaml](peer-orderer.yaml): contains the orderer docker container configuration for the Orderer organization.
* [peer-ptb.yaml](peer-ptb.yaml): contains the docker containers configuration for the PTB peers. It extends the file [peer-base.yaml](peer-base.yaml), which constitutes a template of standard configuration items.
* [peer-inmetro.yaml](peer-inmetro.yaml): contains the docker containers configuration for the Inmetro peers. It also extends the file [peer-base.yaml](peer-base.yaml), just like the PTB peers configuration.
* [.env](.env): this file works as a source for environment variables in the docker configuration. So we use it to transcribe the IP addresses of each peer.

If you are not used to the Hyperledger Fabric, we strongly recommend this [tutorial](https://hyperledger-fabric.readthedocs.io/en/release-1.4/build_network.html). It teaches in detail how to create a basic Fabric network.

You can load and use the Inter-NMI network by executing the steps in the following subsections. You must execute all the commands into the repository base folder.

### 1. Prepare the host machine.

You need to install the **Hyperledger Fabric 1.4 LTS** basic software and [dependencies](https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html). We try to make things simpler by providing a shell script that installs all these stuff (including the Fabric's **docker images in the version 1.4.9**) in a clean **Ubuntu 20.04 LTS** system. If you are using this distribution, our script works for you. If you have a different distribution, you can still try the script or customize it to work in your system.

Execute the [installation script](prerequirements/installFabric.sh):

```console
./installFabric.sh
```

**OBSERVATION**: You do not need to run the script as *sudo*. The script will automatically ask for your *sudo* password when necessary. That is important to keep the docker containers running with your working user account.

### 2. Generate the MSP artifacts

The MSP artifacts include all the cryptographic stuff necessary to identify the peers of a Fabric network. They are basically asymmetric cryptographic key pairs and self-signed digital certificates. Since the Inter-NMI is a multi-host configuration, the hosts must have the same MSP artifacts. Currently, we are working on security policy to generate and distribute the MSP artifacts among organizations. As a workaround, only one organization must execute this procedure and replicate the MSP artifacts for the others. 

Before executing this step, check if the environment variable FABRIC_CFG_PATH is properly defined. If it is not, uncomment the following line in the script [configmsp.sh](configmsp.sh).

```console
export FABRIC_CFG_PATH=$PWD
```

After, execute the script:

```console
./configmsp.sh
```

This script uses [crypto-config-nmi.yaml](crypto-config-nmi.yaml) to create the MSP certificates in the folder **crypto-config**. It also uses [configtx.yaml](configtx.yaml) and generates the genesis block file *nmi-genesis.block*, the channel configuration file *nmi-channel.tx*, and the anchor peers transaction files *ptb.de-anchors.tx* and *inmetro.br-anchors.tx*. Notice that this script depends on the tools installed together with Fabric. The script *installFabric.sh* executed previously is expected to modify your $PATH variable and enable the Fabric tools' direct execution. If this does not happen, try to fix the $PATH manually. The tools usually are in the folder /$HOME/fabric-samples/bin.

### 3. Manage the docker containers

We use the **docker-compose** tool to manage the docker containers in our network. It reads the peer-*.yaml files and creates/starts/stops all the containers or a specific group of containers. You can find more details in the [Docker Compose Documents](https://docs.docker.com/compose/).

Before starting, you must check the proper content in the file [.env](.env). This file constitutes a mechanism to use environment variables into the docker-compose configuration files (*.yaml). In our case, specifically, we use the  *.env* to define the external IP addresses of our servers. This definition is necessary at the moment since we are working with virtual domain names. So check your *.env* file and verify if the IP addresses are correct before continuing.

You must use the following command with the respective organization config to start the containers. If your organization is PTB, your command will be:

```console
docker-compose -f peer-ptb.yaml up -d
```

If your organization is also responsible for hosting the orderer service, you also need to start it. You can use the same command mentioned before, only replacing the .yaml file with [peer-orderer.yaml](peer-orderer.yaml). If this container is running in the same server that hosts your ordinary containers, you *MUST* start them together, by informing both files:

```console
docker-compose -f peer-orderer.yaml -f peer-ptb.yaml up -d
```

The same tool can be used to stop the containers, just if you need to stop the blockchain network for any reason. In a similar manner as done before, use the following command to stop all the containers:

```console
docker-compose -f peer-ptb.yaml stop
```

If you need to reset and restart a complete new set of peers, use the provided script [teardown.sh](teardown.sh), informing the same .yaml file used to start the containers before, for instance:

```console
./teardown.sh peer-ptb.yaml
```

### 4. Create the Fabric channel and join the peers

The next step consists of creating a channel (in practice, the ledger among the peers) and joining all the active peers on it. It is important to remember that we create a channel only once. Thus the first organization to start its peers *MUST* create the channel. The following organizations will only fetch for an existing channel and join on it. The script [configchannel.sh](configchannel.sh) implements both situations. You need to execute it informing your organization domain (e.g., ptb.de or inmetro.br) and the parameter *-c* if you also want to create the channel:

```console
./configchannel.sh ptb.de -c
```

If you succeed in coming so far, the Hyperledger Fabric shall be running in your server, with an instance of your organization network profile. You can see information from the containers by using the following commands:

```console
docker ps
docker stats
```

### 5. Manage a chaincode

Chaincodes are smart contracts in Fabric. In this document, we assume you already know how to implement and deploy a chaincode. If it is not your case, there is a [nice tutorial](https://hyperledger-fabric.readthedocs.io/en/release-1.4/chaincode4ade.html) covering a lot of information about this issue. We strongly recommend you to check it before continuing.

If you already know everything you need about developing and deploying a chaincode, we can talk about installing, instantiate, and upgrade chaincodes in the Inter-NMI blockchain network. We use the **fabpki** chaincode as an example, which we developed in one of our [previous works](https://doi.org/10.1109/MetroInd4.0IoT48571.2020.9138246).
This chaincode contains basic methods that provide elementary PKI services by using the [Golang ECDSA Library](https://golang.org/pkg/crypto/ecdsa/). A copy of the chaincode source is available [here](fabpki/fabpki.go). If you need more details about this chaincode implementation, please consult our paper.

Our blockchain network profiles include, for each organization, a client container *cli0*, which effectively manages chaincodes. The *cli0* is necessary to compile the chaincode and install it in an endorser peer. It is also handy to test chaincodes. It provides an interface to execute the command *peer chaincode*, whose documentation is available [here](https://hyperledger-fabric.readthedocs.io/en/release-1.4/commands/peerchaincode.html). We strongly recommend you read this documentation before continuing.

By default, we associate *cli0* with the *peer0* of the respective organization. However, you can easily change it to work with the *peer1* too. You also can replicate its configuration to create additional client containers. We provide the script [configchaincode.sh](configchaincode.sh) that encapsulates the use of a client container and simplifies the chaincode life cycle management. The script has the following syntax:

```console
./configchaincode.sh install|instantiate|upgrade <CLI container> <chaincode name> <chaincode version>
```

#### How to install a chaincode

Use the **install** command to enable the chaincode execution for a given peer. In practice, you are making this peer an __endorser__. You must re-execute the install command every time you change the chaincode version. Assuming you are using cli0 to install the chaincode fabpki, version 1.0, your command will be:

```console
./configchaincode.sh install cli0 fabpki 1.0
```

Remember that the chaincode source code must be in a folder with the same name, into your base folder, just like we did with the provided [fabpki](fabpki) example.

#### How to instantiate a chaincode

Use the **instantiate** command to instantiate the chaincode in the Inter-NMI default channel, i.e., **nmi-channel**. In practice, you notify the blockchain network that the chaincode exists (by creating an entry in the ledger with the chaincode hash) and consequently authorizing endorser peers to execute it.

```console
./configchaincode.sh instantiate cli0 fabpki 1.0
```

IMPORTANT: While the install command defines endorser peers, the instantiate command notifies all the peers in a channel that they may execute the chaincode. Consequently, you can perform the install on many peers as necessary. On the other hand, you perform the instantiate only once. If another organization already instantiate the chaincode, you do not need to (and in fact, you cannot) instantiate it again. If you change anything in your chaincode, you will need to upgrade it, as we describe in the next section.

#### How to upgrade a chaincode

Use the **upgrade** command to enable a new version of the chaincode. That is necessary for any chaincode that you instantiated before. Notice that an upgraded chaincode needs to be re-installed in each one of its endorser peers.

```console
./configchaincode.sh upgrade cli0 fabpki 1.1
```

## Dealing with client applications

The client application is a set of Python 3 modules that use the blockchain network's chaincode services. They use the Python ECDSA library (which implements our cryptosystem) and the Fabric Python SDK.

You need to install some dependencies and libraries before getting the clients running correctly. We described all the steps necessary to prepare your machine to do that.

### Get pip3

Install the Python PIP3 using the following command:

```console
sudo apt install python3-pip
```

### Get the ECDSA Python Library

The ECDSA library implements the directives related to the Elliptic Curves algorithms. You can find more details [here](https://pypi.org/project/ecdsa/). Run the following command to install the ECDSA library.

```console
pip3 install ecdsa
```

### Get the Fabric Python SDK

The [Fabric Python SDK](https://github.com/hyperledger/fabric-sdk-py) is not part of the Hyperledger Project. It is maintained by an independent community of users from Fabric. However, this SDK works fine, at least to the basic functionalities we need.

Recently, we had problems with broke interfaces that made our programs stoped of running. Thus we adopted the 0.8.0 version of the Python SDK (and the respective tag) as our "stable" version.

You need to install the Python SDK dependencies first:

```console
sudo apt-get install python-dev python3-dev libssl-dev
```

Finally, install the Python SDK using *git*. Notice that the repository is cloned into the current path, so we recommend installing it in your $HOME directory. After cloning the repository, it is necessary to check out the tag associated with the version 0.8.0.

```console
cd $HOME
git clone https://github.com/hyperledger/fabric-sdk-py.git
cd fabric-sdk-py
git checkout tags/v0.8.0
sudo make install
```

### Configure the JSON network profile
The Python SDK applications depend on a **network profile** encoded in JSON format. Since we have two independent organizations, the network profile changes accordingly to them. In this repository, we provide the files [ptb.de.json](fabpki-cli/ptb.de.json) and [inmetro.br.json](fabpki-cli/inmetro.br.json). The network profile keeps the necessary credentials to access the blockchain network. You must configure this file properly every time that you create new digital certificates in the MSP:

* Open the respective .json in a text editor;
* Check for the entries called "tlsCACerts", "clientKey", "clientCert", "cert" and "private_key" on each organization. Notice that they point out to different files into the (./cripto-config) directory that corresponds to digital certificates and keys of each organization. The private key must correspond to the user who will submit the transactions (by default, we use Admin);
* Check the MSP file structure in your deployment and verify the correct name of the files that contain the certificates or keys;
* Modify the .json file with the correct name and path of each required file;
* Also, verify the explicit IP addresses related to the known orderer and entry peer. They must reflect your network configuration.

### The Client Application modules

The Client Application includes the following modules:

* [keygen-ecdsa.py](fabpki-cli/keygen-ecdsa.py): It is a simple Python script that generates a pair of ECDSA keys. These keys are necessary to run all the other modules.
* [register-ecdsa.py](fabpki-cli/register-ecdsa.py): It invokes the *registerMeter* chaincode, which appends a new meter digital asset into the ledger. You must provide the respective ECDSA public key.
* [verify-ecdsa.py](fabpki-cli/verify-ecdsa.py): It works as a client that verifies if a given digital signature corresponds to the meter's private key. The client must provide a piece of information and the respective digital signature. The client module will inform **True** for a legitimate signature and **False** in the opposite.

## Monitoring local ledger copies with Fauxton and Mango

One of the advantages of using CouchDB is its database management system (DBMS) graphical interface. One can access the [Fauxton](https://couchdb.apache.org/fauxton-visual-guide/index.html#using-fauxton) project's web interface instance on each CouchDB container. First, observe in the docker containers list the active CouchDB containers (for example, in the ptb.de domain, they should be ptbdb0 and ptbdb1):

```console
docker ps | grep couchdb
```

In the returned containers list, notice the respective ports where each container is listening to for connections. For instance, the default configuration sets ptbdb0 and ptbdb1 in ports 5984 and 6984, respectively. Now, by assuming you have an Internet browser in your blockchain host, you can access the ptbdb0's Fauxton interface in the following URL: http://localhost:5984/_utils. Observe that you need to change this URL according to your own configuration (i.e., replace localhost with the respective IP and the port number with your own configuration port).

Once you have the CouchDB web interface opened, access the chaincode *fabpki* records link by clicking on the **nmi-channel_fabpki** option. You will be able to consult all the digital assets associated with this chaincode.

**IMPORTANT:** The CouchDB web interface does NOT use blockchain access mechanisms. It gives a direct view corresponding to the local ledger's copy in the respective peer container. Remember that any changes in the local ledger instance may compromise this replica.

CouchDB web interface also integrates the **Mango** tool for querying data. You need to write these queries in JSON format. At first glance, this format is a little complex. However, these JSON queries still make it easier to retrieve information from CouchDB. You can learn a little about Mango queries [here](https://docs.couchdb.org/en/latest/intro/tour.html?highlight=mango#running-a-mango-query). The code below illustrates how to run a query using Mango. Click on the option **Run a Query with Mango**, copy the code below to the **Mango Query** textbox, click on the **Run Query** button and observe the result. You will see that this query returns the record where the meter ID is "123".

```console
{
   "selector": {
      "_id": "123"
   }
}
```

## Using the Hyperledger Explorer

The [Hyperledger Explorer](https://www.hyperledger.org/projects/explorer) is a web tool that helps to monitor the blockchain network with a friendly interface. Our repository includes the extensions to use Explorer together with our experiment. We take the Explorer container-based distribution, that consists of two Docker images:
* **explorer**: a web server that delivers the application.
* **explorer-db**: a PostgreSQL database server that is required to run Explorer.

The following steps describe how to start and stop Explorer. Firstly, make sure that the blockchain network is up and that you executed the previous steps related to install and instantiate the *fabpki* chaincode. You can check these points with the following command:

```console
docker ps
```
The Explorer is also a blockchain client. Before continuing, you must fix the Explorer connection profile, just like you did previously to the Python client. Again, we have this configuration in the files [ptb.de.json](explorer/ptb.de.json) and [inmetro.br.json](explorer/inmetro.br.json) file. Notice that these files are very similar to our Python client connection profile. The procedure to fix them is also the same, with the difference that the Explorer **must** use the Admin credentials. Find the entries called "tlsCACerts", "clientKey", "clientCert", "signedCert" and "adminPrivateKey" of each organization. Replace them with the respective filenames in your MSP configuration, when necessary. **Do not change the files path** because it already points to the container's internal path that the Explorer knows (i.e., the path "/tmp/crypto" maps your local "./crypto-config" folder). Finally, edit the file [config.json](explorer/config.json) to point out for your organization connection profile (PTB or Inmetro).

Now, access the [explorer](explorer) folder and start the Hyperledger Explorer containers. If you are working with the PTB organization, your command is:
```console
cd explorer
docker-compose -f explorer-ptb.yaml up -d
```

The first execution will pulldown the Docker images, and also create the PostgresSQL database. These procedures can require some time to execute. Wait 30 seconds and open the following local address in a web browser: [http://localhost:8080](http://localhost:8080). You must see the Hyperledger Explorer login screen.

If you need to stop or shut down the Hyperledger Explore, proceed with the respective *docker-compose* commands, using *stop* to suspend the container's execution and *down* to remove the containers' instances. Here is an example:
```console
docker-compose -f explorer-ptb.yaml down
```

Eventually, you will need to remove the database volumes associated with the Hyperledger Explorer physically. You can do that by executing the following commands:
```console
docker volume prune
docker volume rm explorer_pgdata explorer_walletstore
```
