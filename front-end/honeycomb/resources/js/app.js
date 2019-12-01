require('./bootstrap');
require('./script');

import Web3 from "web3";
const web3 = new Web3(Web3.givenProvider || "http://localhost:8545");
var abi = require('./abi');
let btn = document.getElementById('testbtn')
// btn.onclick = function test()
// {
//     web3.eth.getAccounts().then(e => document.getElementById('testbox').innerHTML +=  e[0]);
// }

btn.onclick = function test() {

    var contract = new web3.eth.Contract(abi, '0xdB824df2788FF1Cb086773a94708e690EA555b91');

    contract.methods.equipmentAvailableDuringPeriod('1', '80', '90').call()


}
