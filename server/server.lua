local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP")

RegisterNetEvent("nfr_banking:requestMoneyAmountInBank")
AddEventHandler(
    "nfr_banking:requestMoneyAmountInBank",
    function()
        local user_id = vRP.getUserId({source})
        local userbankBalanace = vRP.getBankMoney({user_id})
        TriggerClientEvent("nfr_banking:updateBankBalance", source, userbankBalanace, user_id)
    end
)

RegisterNetEvent("nfr_banking:action")
AddEventHandler(
    "nfr_banking:action",
    function(data)
        local user_id = vRP.getUserId({source})
        local userbankBalanace = vRP.getBankMoney({user_id})
        local userBalance = vRP.getMoney({user_id})
        TriggerClientEvent("nfr_banking:updateBankBalance", source, userbankBalanace, user_id)
        if (data.action == "withdraw") then
            local amountToWithdraw = tonumber(data.amount)
            if amountToWithdraw <= 0 then
                vRPclient.notify(source,{"Eroare: Nu ai cum sa retragi sume nule de bani!"})
                return
            end
            if amountToWithdraw > userbankBalanace then
                vRPclient.notify(source,{"Eroare: Nu ai destui bani in banca pentru a retrage aceasta suma de bani!"})
                return
            else
                vRP.setBankMoney({user_id,userbankBalanace - amountToWithdraw})
                vRP.setMoney({user_id,userBalance + amountToWithdraw})
                vRPclient.notify(source,{string.format("Succes: Ai retras cu succes din banca suma de %s$. Noua ta balanta in banca este %s$!",amountToWithdraw,userbankBalanace - amountToWithdraw)})
                return
            end
        end
        if (data.action == "deposit") then
            local amountToDeposit = tonumber(data.amount)
            if amountToDeposit <= 0 then
                vRPclient.notify(source,{"Eroare: Nu ai cum sa depozitezi sume nule de bani!"})
                return
            end
            if amountToDeposit > userBalance then
                vRPclient.notify(source,{"Eroare: Nu ai destui bani la tine pentru a depozita aceasta suma de bani!"})
                return
            else
                vRP.setBankMoney({user_id,userbankBalanace + amountToDeposit})
                vRP.setMoney({user_id,userBalance - amountToDeposit})
                vRPclient.notify(source,{string.format("Succes: Ai depozitat cu succes in banca suma de %s$. Noua ta balanta in banca este %s$!",amountToDeposit,userbankBalanace + amountToDeposit)})
                return
            end
        end
        if (data.action == "transfer") then
            local target_user_id = data.userid
            local target_source = vRP.getUserSource({tonumber(target_user_id)})
            local amountToTransfer = tonumber(data.amount)
            if target_source == nil then
                vRPclient.notify(source,{"Eroare: Acest cetatean nu se afla momentan in oras, incearca mai tarziu!"})
                return
            end
            if tonumber(target_user_id) == tonumber(user_id) then
                vRPclient.notify(source,{"Eroare: Nu ai cum sa iti trimiti bani singur!"})
                return
            end
            if amountToTransfer > userbankBalanace then
                vRPclient.notify(source,{"Eroare: Nu ai destui bani in banca pentru a transfera aceasta suma!"})
                return
            else
                local target_bankBalance = vRP.getBankMoney({target_user_id})
                vRP.setBankMoney({target_user_id,target_bankBalance + amountToTransfer})
                vRP.setBankMoney({user_id,userbankBalanace - amountToTransfer})
                vRPclient.notify(source,{string.format("Succes: Ai transferat cu succes suma de %s$ catre cetateanul cu ID-ul %s. Noua ta balanca in banca este %s$!",amountToTransfer, amountToTransfer, userbankBalanace - amountToTransfer)})
                vRPclient.notify(target_source,{string.format("Succes: Ti-a fost transferata cu succes in banca suma de %s$ de la cetateanul cu ID-ul %s. Noua ta balanta in banca este %s$!",amountToTransfer,user_id,userbankBalanace + amountToTransfer)})
                return
            end
        end
    end
)
