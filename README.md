## Recon script 
This is my intial recon script.This has given me some great finding in past.
This script uses some well known tools like httpx, waybackurls, amass, etc and as well as some of my own scripts. 

### Features 
This is the normal workflow of the script.
1. Get subdomains passively from amass and subfinder.
2. Create some permutations from my wordlist.
3. Use dnsgen for more permutations.
4. Using massdns for resolve all subdomain.
5. Filter the output from massdns into subdomains , IPs and CNAMES.
6. Run httpx on the resolved subdomains to check which are alive.
7. Run my custom scripts to jsfiles , and header and response.

### Work in progress
1.Update the custom to get more jsfiles.
2.Auto updation of wordlist so that result get better each time it runs.
