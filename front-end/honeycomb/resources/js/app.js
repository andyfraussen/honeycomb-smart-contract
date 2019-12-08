require('./bootstrap');
require('./script');
var abi = require('./abi');

let btn = document.getElementById('checkoutButton')

btn.onclick = async () => {
    if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        try {
            await ethereum.enable();
            var contract = web3.eth.contract(abi, '0x26B7FD747CE99d8d7a6271CA66AD3915AED28476');
            var contractInstance = contract.at('0x26B7FD747CE99d8d7a6271CA66AD3915AED28476')
            contractInstance.gasPrice = 21000;
            var equipmentid = document.getElementById('productid').innerHTML
            var startdate = document.getElementById('startdate').value
            var enddate = document.getElementById('enddate').value
            var windspeed = document.getElementById('windspeed').value

            contractInstance.equipmentAvailableDuringPeriod(equipmentid, startdate, enddate, e => console.log(e));
            contractInstance.registerRentalContract(equipmentid, 1, startdate, enddate, windspeed, 0.2, e =>
                console.log(e)
            )
        } catch (error) {
            // User denied account access...
            console.log(error)
        }
    }
};

