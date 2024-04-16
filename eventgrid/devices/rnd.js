/**
* @description: default script
* @param {any} value - Payload
* @param {string} msgType - Message type, value is 'received' or 'publish'
* @param {number} index - Index of the message, valid only when script is used in the publish message and timed message is enabled
* @return {any} - Payload after script processing
*/
function handlePayload(value, msgType, index) {
    if(msgType==="publish"){
      if(value.msg=="hello"){
        if(Math.random()>0.5){
          data+=Math.random()*2.5;
        }
        else
          data-=Math.random()*2.5;
        return JSON.stringify({'value':data});
      }
    }
  
    return value.msg
  }
  
  var data=10
  
  execute(handlePayload)