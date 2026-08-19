/**
 * Trigger : calcule automatiquement le montant net (Order.NetAmount__c)
 * de chaque commande avant sa mise à jour.
 *
 * Formule :
 * NetAmount__c = TotalAmount - ShipmentCost__c
 *
 * Bug corrigé :
 * L'ancienne version ne traitait que la première commande du contexte
 * avec "Order newOrder = Trigger.new[0];".
 *
 * Lors d'une mise à jour groupée, par exemple avec Data Loader, plusieurs
 * commandes peuvent être présentes dans Trigger.new. Seule la première
 * était donc recalculée.
 *
 * Le trigger parcourt désormais l'ensemble de Trigger.new afin de recalculer
 * le montant net de chaque commande, quel que soit le nombre de commandes
 * traitées dans la transaction.
 *
 * Les valeurs nulles de TotalAmount et ShipmentCost__c sont remplacées
 * par 0 afin d'éviter un résultat null lors du calcul.
 */
trigger OrderNetAmountTrigger on Order (before update) {

    // Parcourt toutes les commandes de la transaction.
    for (Order currentOrder : Trigger.new) {

        // Récupère le montant total de la commande.
        Decimal totalAmount = currentOrder.TotalAmount == null
            ? 0
            : currentOrder.TotalAmount;

        // Récupère les frais de livraison.
        Decimal shipmentCost = currentOrder.ShipmentCost__c == null
            ? 0
            : currentOrder.ShipmentCost__c;

        // Calcule et renseigne le montant net.
        currentOrder.NetAmount__c = totalAmount - shipmentCost;
    }
}