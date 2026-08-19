import { LightningElement, api, wire } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

/**
 * Composant LWC permettant d'afficher le total des commandes
 * rattachées au compte courant.
 *
 * Le composant récupère l'Id du compte grâce à recordId et appelle
 * la méthode Apex getSumOrdersByAccount avec @wire.
 *
 * Si aucune commande n'est trouvée, si le montant total est égal à 0
 * ou inférieur à 0, un message d'erreur est affiché.
 * Dans le cas contraire, le montant total des commandes est affiché.
 */
export default class AccountOrdersSummary extends LightningElement {

    @api recordId;

    sumOrdersOfCurrentAccount;
    hasError = false;

    /**
     * Récupère le total des commandes du compte courant.
     *
     * data  : montant total retourné par Apex.
     * error : erreur lors de l'appel de la méthode Apex.
     */
    @wire(getSumOrdersByAccount, { accountId: '$recordId' })
    wiredSumOrders({ data, error }) {
        if (data !== undefined) {
            this.sumOrdersOfCurrentAccount = data;

            // Une valeur nulle, égale à 0 ou négative est considérée comme une erreur.
            this.hasError = !data || data <= 0;
        } else if (error) {
            // En cas d'erreur Apex, on affiche le message d'erreur.
            this.hasError = true;
            this.sumOrdersOfCurrentAccount = undefined;
        }
    }
}
