/**
 * Trigger permettant de calculer automatiquement le montant net
 * d'une commande à partir de son montant total et de ses frais de livraison.
 *
 * Le calcul est effectué avant l'insertion et avant la modification
 * de la commande afin que NetAmount__c soit toujours à jour.
 */
trigger CalculMontant on Order (before insert, before update) {

    // Parcourt toutes les commandes concernées par la transaction.
    // Cette boucle permet de respecter le principe de bulkification Salesforce.
    for (Order orderRecord : Trigger.new) {

        // Récupère le montant total de la commande.
        // Si TotalAmount est null, on utilise 0.
        Decimal totalAmount = orderRecord.TotalAmount != null
            ? orderRecord.TotalAmount
            : 0;

        // Récupère les frais de livraison.
        // Si ShipmentCost__c est null, on utilise 0.
        Decimal shipmentCost = orderRecord.ShipmentCost__c != null
            ? orderRecord.ShipmentCost__c
            : 0;

        // Calcule le montant net :
        // montant total - frais de livraison.
        orderRecord.NetAmount__c = totalAmount - shipmentCost;
    }
}