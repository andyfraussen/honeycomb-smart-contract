let abi = require('./abi.json');

let availableButton = document.getElementById('availableButton')
let registerButton = document.getElementById('registerButton')
let confirmButton = document.getElementById('confirmButton')

availableButton.onclick = async () => {
    if (window.ethereum) {
        //window.web3 = new Web3(ethereum);
        try {
            await ethereum.enable();
            let contract = web3.eth.contract(abi);
            let contractInstance = contract.at('0x40D8d66A03c1c2949837FffC241CE078AD0B15FA')

            let equipmentid = parseInt(document.getElementById('equipmentId').value);
            let rentalId = parseInt(Math.floor(Math.random() * 101));
            let equipmentIdGroup = document.getElementById('equipmentId').value
            let date = document.getElementById('rentalDate').value
            let windspeed = parseInt(document.getElementById('windspeedSelect').value)
            let location = document.getElementById('locationSelect').value
            let serviceFee = 10000

            contractInstance.equipmentAvailable(equipmentid, date.toString(), (e, f) => {
                if (f === true) {
                    alert('Date is still available! Continue to the last step to register the rental')
                }
            })
            document.getElementById('equipmentIdGroup').innerText = 'Equipment ID: '+equipmentid
            document.getElementById('dateGroup').innerText = 'Date: ' + date
            document.getElementById('rentalIdGroup').innerText = 'RentalID: ' + rentalId
            document.getElementById('LocationGroup').innerText = 'Location: ' + location
            document.getElementById('WindspeedGroup').innerText = 'Min windspeed: ' + windspeed
            document.getElementById('serviceFeeGroup').innerText = 'Servicefee: ' + serviceFee
            let amount = 10000000000000000
            let gasValue = 500000

            registerButton.onclick = function () {
                contractInstance.registerRentalContract(equipmentid, rentalId, date.toString(), windspeed, location, serviceFee, '0xdB824df2788FF1Cb086773a94708e690EA555b91',
                    {from: window.web3.currentProvider.selectedAddress, value: amount, gas: gasValue, gasPrice: 10000}, (err, call) => {
                        console.log(err, call)
                    })
                document.getElementById('confirmEquipment').value = equipmentid
                document.getElementById('confirmRental').value = rentalId
            }

            confirmButton.onclick = function(){

                let equipmentConfirm = parseInt(document.getElementById('confirmEquipment').value)
                let rentalConfirm = parseInt(document.getElementById('confirmRental').value)

                contractInstance.requestSettlement(equipmentConfirm, rentalConfirm, (err, call) => {
                    console.log(err, call)})
            }

        } catch (error) {
            // User denied account access...
            //alert("We couldn't connect to MetaMask. Please check if you're logged in or MetaMask is installed!")
        }
    }
}




