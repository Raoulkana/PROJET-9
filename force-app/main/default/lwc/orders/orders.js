import { LightningElement, api, wire } from 'lwc';
import getSumOrdersByAccount from '@salesforce/apex/MyTeamOrdersController.getSumOrdersByAccount';

/**
 * Composant LWC permettant d'afficher le montant total
 * des commandes rattachées au compte courant.
 *
 * La méthode Apex getSumOrdersByAccount est appelée automatiquement
 * avec l'Id du compte grâce à @wire.
 *
 * Si le montant est vide, égal à 0 ou inférieur à 0,
 * le composant affiche un message d'erreur.
 */
export default class Orders extends LightningElement {

    @api recordId;

    sumOrdersOfCurrentAccount;
    hasError = false;

    /**
     * Récupère le montant total des commandes du compte courant.
     *
     * recordId correspond à l'Id du compte sur lequel le composant
     * est affiché.
     */
    @wire(getSumOrdersByAccount, { accountId: '$recordId' })
    wiredSumOrders({ data, error }) {

        if (data !== undefined) {
            this.sumOrdersOfCurrentAccount = data;

            // Une valeur vide, égale à 0 ou négative est considérée comme une erreur.
            this.hasError = !data || data <= 0;

        } else if (error) {
            // En cas d'erreur lors de l'appel Apex, on affiche le message d'erreur.
            this.hasError = true;
            this.sumOrdersOfCurrentAccount = undefined;
        }
    }
}