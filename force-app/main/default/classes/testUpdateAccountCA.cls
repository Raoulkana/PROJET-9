/**
 * Tests du trigger UpdateAccountCA et de la classe de service UpdateAccounts.
 *
 * Vérifie le calcul du chiffre d'affaires d'un compte lors de l'activation
 * d'une commande et couvre notamment la non-régression liée à la
 * bulkification au-delà de 100 commandes.
 */
@isTest
private class testUpdateAccountCA {

    /**
     * Vérifie que le chiffre d'affaires du compte est correctement mis à jour
     * lorsqu'une commande est activée.
     */
    @isTest
    static void testChiffreAffairesUpdatedWhenOrderActivated() {
        Account acc = TestDataFactory.createAccount('Client Test');
        PricebookEntry pbe = TestDataFactory.createStandardPricebookEntry(150);

        Test.startTest();

        // Création et activation d'une commande de 10 unités à 150 €.
        // Le CA attendu pour le compte est donc de 1 500 €.
        TestDataFactory.createOrdersWithItems(
            acc.Id,
            pbe.Id,
            1,
            150,
            10,
            true
        );

        Test.stopTest();

        Account refreshed = [
            SELECT Chiffre_d_affaire__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            1500,
            refreshed.Chiffre_d_affaire__c,
            'Le chiffre d\'affaires doit correspondre au montant total de la commande activée.'
        );
    }

    /**
     * Vérifie que le calcul reste fonctionnel avec un volume important
     * de commandes activées sur un même compte.
     *
     * Ce test couvre la non-régression du problème de bulkification qui
     * provoquait auparavant une erreur "Too many SOQL queries: 101".
     */
    @isTest
    static void testChiffreAffairesBulkOver100Orders() {
        Account acc = TestDataFactory.createAccount('Client Volume');
        PricebookEntry pbe = TestDataFactory.createStandardPricebookEntry(100);

        Test.startTest();

        // Création de 150 commandes afin de reproduire une mise à jour bulk
        // supérieure à la limite de 100 requêtes SOQL.
        TestDataFactory.createOrdersWithItems(
            acc.Id,
            pbe.Id,
            150,
            100,
            1,
            true
        );

        Test.stopTest();

        Account refreshed = [
            SELECT Chiffre_d_affaire__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            15000,
            refreshed.Chiffre_d_affaire__c,
            'Le CA doit être correctement calculé même avec plus de 100 commandes.'
        );
    }

    /**
     * Vérifie qu'une modification ultérieure du catalogue ne modifie pas
     * le chiffre d'affaires d'une commande déjà activée.
     *
     * Salesforce ne permet pas de modifier directement le prix d'un
     * PricebookEntry dans ce scénario de test. Un second PricebookEntry
     * est donc créé avec un nouveau prix afin de simuler une évolution
     * du tarif catalogue.
     */
    @isTest
    static void testChiffreAffairesNotImpactedByLaterPriceChange() {
        Account acc = TestDataFactory.createAccount('Client Prix');
        PricebookEntry pbe = TestDataFactory.createStandardPricebookEntry(150);

        Test.startTest();

        // Activation de la commande avec un prix de 150 € et une quantité de 10.
        TestDataFactory.createOrdersWithItems(
            acc.Id,
            pbe.Id,
            1,
            150,
            10,
            true
        );

        // Création d'un nouveau Price Book avec un prix différent pour
        // le même produit afin de simuler un changement de tarif catalogue.
        Pricebook2 newPricebook = new Pricebook2(
            Name = 'Nouveau Tarif',
            IsActive = true
        );

        insert newPricebook;

        insert new PricebookEntry(
            Pricebook2Id = newPricebook.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = 999,
            IsActive = true
        );

        Test.stopTest();

        Account refreshed = [
            SELECT Chiffre_d_affaire__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        System.assertEquals(
            1500,
            refreshed.Chiffre_d_affaire__c,
            'Un nouveau prix catalogue ne doit pas modifier le CA d\'une commande déjà activée.'
        );
    }

    // Vérification CI/CD : validation de l'exécution complète des tests
    // et du bon fonctionnement du pipeline après modification du trigger.
}