/**
 * Trigger : met à jour le chiffre d'affaires des comptes concernés
 * lorsqu'une commande est modifiée.
 *
 * Le chiffre d'affaires du compte est calculé à partir de la somme
 * des TotalAmount de ses commandes.
 *
 * Cette version est bulkifiée :
 * - aucun SOQL dans une boucle ;
 * - aucun DML dans une boucle ;
 * - toutes les commandes de Trigger.new sont traitées ;
 * - les anciens et nouveaux comptes sont pris en compte si
 *   AccountId est modifié.
 */
trigger UpdateAccountCA on Order (after update) {

    // Stocke les comptes concernés par les modifications.
    Set<Id> accountIds = new Set<Id>();

    for (Order newOrder : Trigger.new) {

        // Ajoute le nouveau compte si la commande en possède un.
        if (newOrder.AccountId != null) {
            accountIds.add(newOrder.AccountId);
        }

        // Ajoute également l'ancien compte si la commande
        // a changé de compte.
        Order oldOrder = Trigger.oldMap.get(newOrder.Id);

        if (oldOrder.AccountId != null) {
            accountIds.add(oldOrder.AccountId);
        }
    }

    // Aucun compte concerné : rien à faire.
    if (accountIds.isEmpty()) {
        return;
    }

    // Calcule le total des commandes pour chaque compte.
    Map<Id, Decimal> accountTotals = new Map<Id, Decimal>();

    for (AggregateResult result : [
        SELECT AccountId accountId, SUM(TotalAmount) totalAmount
        FROM Order
        WHERE AccountId IN :accountIds
        GROUP BY AccountId
    ]) {
        accountTotals.put(
            (Id) result.get('accountId'),
            (Decimal) result.get('totalAmount')
        );
    }

    // Récupère les comptes concernés.
    List<Account> accountsToUpdate = [
        SELECT Id, Chiffre_d_affaire__c
        FROM Account
        WHERE Id IN :accountIds
    ];

    // Met à jour le chiffre d'affaires de chaque compte.
    for (Account account : accountsToUpdate) {
        account.Chiffre_d_affaire__c =
            accountTotals.containsKey(account.Id)
                ? accountTotals.get(account.Id)
                : 0;
    }

    // Un seul DML pour tous les comptes.
    update accountsToUpdate;
}