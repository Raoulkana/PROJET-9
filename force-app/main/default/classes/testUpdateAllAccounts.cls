/**
 * Tests du batch UpdateAllAccounts.
 *
 * Vérifie le recalcul en masse du chiffre d'affaires des comptes à partir
 * des commandes déjà activées, notamment dans un contexte de migration
 * ou de reprise de données existantes.
 */
@isTest
private class testUpdateAllAccounts {

    /**
     * Vérifie que le batch recalcule correctement le chiffre d'affaires
     * d'un compte à partir de l'ensemble de ses commandes "Activated".
     */
    @isTest
    static void testBatchRecalculatesChiffreAffaires() {
        Account acc = TestDataFactory.createAccount('Migration Test');
        PricebookEntry pbe = TestDataFactory.createStandardPricebookEntry(200);

        // Simulation d'une migration : les commandes existent déjà
        // au statut "Activated" avant l'exécution du batch.
        TestDataFactory.createOrdersWithItems(
            acc.Id,
            pbe.Id,
            5,
            200,
            2,
            true
        );

        Test.startTest();

        // Exécution du batch avec une taille de lot de 200 enregistrements.
        Database.executeBatch(new UpdateAllAccounts(), 200);

        Test.stopTest();

        Account refreshed = [
            SELECT Chiffre_d_affaire__c
            FROM Account
            WHERE Id = :acc.Id
        ];

        // 5 commandes x 2 unités x 200 € = 2 000 € de chiffre d'affaires.
        System.assertEquals(
            2000,
            refreshed.Chiffre_d_affaire__c,
            'Le batch doit recalculer le CA à partir de toutes les commandes Activated du compte.'
        );
    }

    // Vérification CI/CD : validation de l'exécution complète des tests
    // et du bon fonctionnement du pipeline après modification du batch.
}