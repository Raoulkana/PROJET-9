/**
 * Tests du contrôleur MyTeamOrdersController utilisé par le LWC
 * accountOrdersSummary.
 *
 * Vérifie notamment le calcul du montant total des commandes
 * "Activated" et l'isolation des données entre les comptes.
 */
@isTest
private class testMyTeamOrdersController {

    /**
     * Vérifie que la méthode retourne 0 lorsqu'un compte
     * ne possède aucune commande au statut "Activated".
     */
    @isTest
    static void testReturnsZeroWhenNoActivatedOrders() {
        Account acc = TestDataFactory.createAccount('Sans Commande');

        Test.startTest();
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(
            0,
            total,
            'Le total doit être égal à 0 lorsqu\'aucune commande Activated n\'existe.'
        );
    }

    /**
     * Vérifie que seules les commandes "Activated" du compte
     * sont prises en compte dans le calcul du montant total.
     */
    @isTest
    static void testReturnsSumOfActivatedOrdersOnly() {
        Account acc = TestDataFactory.createAccount('Avec Commandes');
        PricebookEntry pbe = TestDataFactory.createStandardPricebookEntry(100);

        // 2 commandes Activated de 100 = 200.
        TestDataFactory.createOrdersWithItems(
            acc.Id,
            pbe.Id,
            2,
            100,
            1,
            true
        );

        // Cette commande est en Draft et doit être ignorée.
        TestDataFactory.createOrdersWithItems(
            acc.Id,
            pbe.Id,
            1,
            100,
            1,
            false
        );

        Test.startTest();
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(acc.Id);
        Test.stopTest();

        System.assertEquals(
            200,
            total,
            'Seules les commandes Activated du compte doivent être sommées.'
        );
    }

    /**
     * Vérifie que les commandes d'un autre compte ne sont pas
     * incluses dans le calcul du total.
     */
    @isTest
    static void testIgnoresOrdersFromOtherAccounts() {
        Account accountA = TestDataFactory.createAccount('Compte A');
        Account accountB = TestDataFactory.createAccount('Compte B');

        PricebookEntry pbe = TestDataFactory.createStandardPricebookEntry(100);

        // Compte A : 2 commandes Activated = 200.
        TestDataFactory.createOrdersWithItems(
            accountA.Id,
            pbe.Id,
            2,
            100,
            1,
            true
        );

        // Compte B : 3 commandes Activated = 300, qui doivent être ignorées.
        TestDataFactory.createOrdersWithItems(
            accountB.Id,
            pbe.Id,
            3,
            100,
            1,
            true
        );

        Test.startTest();
        Decimal total = MyTeamOrdersController.getSumOrdersByAccount(accountA.Id);
        Test.stopTest();

        System.assertEquals(
            200,
            total,
            'Les commandes des autres comptes ne doivent pas être incluses.'
        );
    }

    // Vérification CI/CD : validation de l'exécution complète des tests
    // et du bon fonctionnement du pipeline après modification du contrôleur.
}
