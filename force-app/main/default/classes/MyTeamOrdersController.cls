/**
 * Contrôleur Apex du composant LWC "accountOrdersSummary".
 *
 * Calcule le montant total des commandes du compte affiché dans le LWC,
 * en prenant uniquement les commandes dont le statut est "Activated".
 * Le contrôleur utilise "with sharing" afin de respecter les règles
 * de partage Salesforce de l'utilisateur connecté.
 */
public with sharing class MyTeamOrdersController {

    /**
     * Retourne le montant total des commandes activées d'un compte.
     *
     * @param accountId Id du compte affiché sur la page Salesforce.
     * @return Somme des TotalAmount des commandes "Activated", ou 0
     *         si aucune commande correspondante n'est trouvée.
     */
    @AuraEnabled(cacheable=true)
    public static Decimal getSumOrdersByAccount(Id accountId) {

        // Aucun compte fourni : aucune commande ne peut être calculée.
        if (accountId == null) {
            return 0;
        }

        // On limite la somme aux commandes du compte courant
        // et uniquement à celles qui sont au statut "Activated".
        AggregateResult groupedResult = [
            SELECT SUM(TotalAmount) total
            FROM Order
            WHERE AccountId = :accountId
            AND Status = 'Activated'
        ];

        Decimal total = (Decimal) groupedResult.get('total');

        // SUM retourne null lorsqu'aucune commande ne correspond.
        // Le LWC reçoit donc toujours une valeur numérique.
        return total == null ? 0 : total;
    }
}