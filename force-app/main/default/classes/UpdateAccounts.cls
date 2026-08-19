/**
 * Service centralisant le recalcul du chiffre d'affaires des comptes.
 *
 * Le chiffre d'affaires est calculé à partir des commandes au statut
 * "Activated". Le calcul est effectué par agrégation afin de rester
 * compatible avec les traitements en masse et d'éviter les problèmes
 * de cumul lorsque plusieurs opérations sont exécutées sur une même
 * commande ou un même compte.
 *
 * Cette classe est notamment utilisée par :
 * - UpdateAccountCA.trigger : recalcul ciblé des comptes concernés.
 * - UpdateAllAccounts.cls : recalcul en masse lors d'une migration
 *   ou d'une reprise de données.
 */
public without sharing class UpdateAccounts {

    private static final String STATUS_ACTIVATED = 'Activated';

    /**
     * Recalcule le chiffre d'affaires des comptes fournis.
     *
     * Une seule requête SOQL agrégée récupère le montant total des
     * commandes "Activated" pour l'ensemble des comptes concernés.
     * Les comptes ne possédant aucune commande activée sont remis à 0.
     *
     * @param accountIds Identifiants des comptes à recalculer.
     */
    public static void recalculateChiffreAffaires(Set<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        Map<Id, Decimal> totalByAccountId = new Map<Id, Decimal>();

        // Agrégation du montant total des commandes activées par compte.
        for (AggregateResult result : [
            SELECT AccountId accId, SUM(TotalAmount) total
            FROM Order
            WHERE AccountId IN :accountIds
            AND Status = :STATUS_ACTIVATED
            GROUP BY AccountId
        ]) {
            totalByAccountId.put(
                (Id) result.get('accId'),
                (Decimal) result.get('total')
            );
        }

        List<Account> accountsToUpdate = new List<Account>();

        // Chaque compte est mis à jour avec son CA calculé.
        // Les comptes sans commande activée sont explicitement remis à 0.
        for (Id accountId : accountIds) {
            accountsToUpdate.add(new Account(
                Id = accountId,
                Chiffre_d_affaire__c = totalByAccountId.containsKey(accountId)
                    ? totalByAccountId.get(accountId)
                    : 0
            ));
        }

        update accountsToUpdate;
    }
}
