/**
 * Batch Apex permettant de recalculer en masse le chiffre d'affaires
 * des comptes concernés.
 *
 * Il est notamment utilisé après une migration ou une reprise de données
 * lorsque des commandes ont été importées directement au statut "Activated"
 * sans déclencher le traitement habituel du trigger UpdateAccountCA.
 *
 * Le calcul est délégué à UpdateAccounts afin de centraliser la logique métier
 * et d'éviter sa duplication entre le trigger et le traitement batch.
 */
global class UpdateAllAccounts implements Database.Batchable<SObject> {

    /**
     * Sélectionne uniquement les comptes possédant au moins une commande
     * au statut "Activated" afin de limiter le traitement aux comptes concernés.
     */
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT Id
            FROM Account
            WHERE Id IN (
                SELECT AccountId
                FROM Order
                WHERE Status = 'Activated'
            )
        ]);
    }

    /**
     * Recalcule le chiffre d'affaires des comptes du lot courant.
     *
     * Le service UpdateAccounts effectue une agrégation des commandes
     * "Activated" afin de calculer le CA de manière bulkifiée.
     */
    global void execute(
        Database.BatchableContext context,
        List<Account> scope
    ) {
        Set<Id> accountIds = (new Map<Id, Account>(scope)).keySet();

        UpdateAccounts.recalculateChiffreAffaires(accountIds);
    }

    /**
     * Méthode exécutée à la fin du batch.
     *
     * Aucun traitement complémentaire n'est nécessaire actuellement,
     * mais cette méthode pourra être utilisée pour ajouter une notification
     * ou un suivi de l'exécution du batch.
     */
    global void finish(Database.BatchableContext context) {
    }

    // Vérification CI/CD : validation de l'exécution complète des tests
    // et du bon fonctionnement du pipeline après modification du batch.
}