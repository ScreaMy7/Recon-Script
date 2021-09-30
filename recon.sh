#!/bin/bash
NORMAL='\e[0m'
RED='\e[31m'
LIGHT_GREEN='\e[92m'
LIGHT_YELLOW='\e[93m'
BLINK='\e[5m'
BOLD='\e[1m'
echo -e"\n${LIGHT_GREEN}Syntax, Arg1 = Domain ,Arg2 = Output File${NORMAL}"
echo -e "\n${LIGHT_YELLOW}Enumerating " $1
echo -e "\n${RED}Consider using amass intel -org to find ASN and lookup CIDR range etc"
echo -e "\n ${RED}Get domains for crt.sh recursively"
CUR_PATH=$(pwd)
mkdir $2
cd $2
subfinder -silent -d $1 -o $2.intialdomains
amass enum -d $1 | tee >> $2.intialdomains
assetfinder --subs-only $1 >> $2.intialdomains

cat $2.intialdomains |sort -u  > all_domains

echo -e "\n${LIGHT_YELLOW}Creating permutations"
bash permutation.sh $1 >> $2_permutation_domains
echo -e "\n\n ${RED}USE ALTdns for big programs"

echo -e "\n ${LIGHT_YELLOW}Useing dnsgen and resolving them"
cat all_domains |dnsgen -  |  ~/tools/massdns/bin/massdns -r $CUR_PATH/wordlist/50resolvers.txt -t A -o S -w $2_massdns_gen

echo -e "\n${LIGHT_YELLOW}Using massdns and subbrute to bruteforce subdomains"
python3 ~/tools/massdns/scripts/subbrute.py $CUR_PATH/wordlist/subdomains.txt $1 | ~/tools/massdns/bin/massdns -r $CUR_PATH/wordlist/50resolvers.txt -t A -o S -w $2_subbrute_dns

echo -e "${LIGHT_YELLOW}Resolving the permutaions"
cat $2_permutation_domains | ~/tools/massdns/bin/massdns -r $CUR_PATH/wordlist/50resolvers.txt -t A -o S -w $2_massdns_permutations

echo -e "\n${LIGHT_YELLOW}Using massdns on intials domains"
cat all_domains | ~/tools/massdns/bin/massdns -r $CUR_PATH/wordlist/50resolvers.txt -t A -o S -w $2_massdns_passive

echo  -e "\n ${LIGHT_YELLOW}Sorting the unique from massdns results "
cat $2_massdns_passive $2_massdns_permutations $2_massdns_gen $2_subbrute_dns |sort -u >resolved_mass_CNAME.txt

echo -e "\n${RED}Use other github and other dorks to more subdomains"

cat resolved_mass_CNAME.txt | sed 's/A.*// ; s/CN.*// ; s/\..$//' >resolved_domains.txt
rm  $2_massdns_passive $2_massdns_permutations $2_massdns_gen $2_subbrute_dns
rm all_domains $2.intialdomains


echo -e "\n${LIGHT_YELLOW}Finding live domains"

cat resolved_domains.txt | httpx -silent|tee alive.txt

echo "\n${LIGHT_GREEN}Subdomain enumeration is finish with "
echo -e "${LIGHT_GREEN}\ntotal alive="
cat alive.txt |wc -l
echo -e "\n${LIGHT_GREEN}total resolved="
cat all_resolved.txt |wc -l


$CUR_PATH/response.sh alive.txt
$CUR_PATH/jsfiles.sh $1