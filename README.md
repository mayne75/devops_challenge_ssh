# devops_challenge_ssh
MVP demo for automating SSH using Hashicorp Vault, Chef Test Kitchen and Docker on AWS. Using the Vault SSH secret backend (vault-*) to secure authentication and authorization to servers (server-a-* and server-b-*) via the SSH protocol. The Vault SSH backend helps manage access to server infrastructure by leveraging Vault's CA capabilities and functionality built into OpenSSH, clients (student-*) can SSH into servers using their own local SSH keys.

## Set-up
First create a VAULT_TOKEN ENV variable to provide authentication to the Vault server. It can be any value you want for thr demo:<br />
$ export VAULT_TOKEN=&lt;my-root-token&gt;<br />
$ echo $VAULT_TOKEN<br />

Then start the Vault server using Kitchen:<br />
$ kitchen converge vault-ubuntu-1604<br />

Once the Vault server has been started, create the VAULT_ADDR ENV variable used to access Vault via it's APIs:<br />
$ export VAULT_ADDR=$(cat .kitchen/vault-*.yml | grep hostname: | cut -d ' ' -f2) && echo $VAULT_ADDR<br />

Start the two Servers which add the public key from Vault to their trusted users:<br />
$ kitchen converge server-a-ubuntu-1604<br />
$ kitchen converge server-b-ubuntu-1604<br />

We will need the hostnames of the servers later for the test:<br />
$ cat .kitchen/server-*.yml | grep hostname: | cut -d ' ' -f2<br />

Finally using Kitchen, start the student machine and login:<br />
$ kitchen converge student-ubuntu-1604<br />
$ kitchen login student-ubuntu-1604<br />

## Test Access
To gain access to either of the Servers use the private key and the public key that has been signed by Vault. Use the hostname of either server:<br />
$ ssh -i .ssh/unsigned.rsa -i .ssh/signed.rsa.pub ubuntu@&lt;ec2-xx-xxx-xx-xxx&gt;.eu-west-2.compute.amazonaws.com<br />

## Revoke Access
Removing the role from Vault via the API still needs to account for the Time To Live (TTL) set when the role was created, once the time has elapsed access will not be possible using the ssh keys. Note use the hostname for Vault (i.e. VAULT_ADDR):<br />
$ curl -s -k -X DELETE -H "x-Vault-Token: &lt;my-root-token&gt;" &lt;ec2-xx-xxx-xx-xxx&gt;.eu-west-2.compute.amazonaws.com/v1/ssh-client-signer/roles/ubuntu<br />

## Clean-up
To shutdown and terminate all the AWS EC2s:<br />
$ kitchen destroy<br />

