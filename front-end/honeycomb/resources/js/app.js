require('./bootstrap');
require('./script');

import Web3 from "web3";
const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");

let btn = document.getElementById('testbtn')
btn.onclick = function test()
{
    web3.eth.getAccounts().then(e => document.getElementById('testbox').innerHTML +=  e[0]);
}

