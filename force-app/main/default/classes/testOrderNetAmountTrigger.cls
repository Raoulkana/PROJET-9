/**
 * Tests du trigger OrderNetAmountTrigger (anciennement CalculMontant.trigger).
 *
 * Vérifie notamment que le montant net de chaque commande est correctement
 * recalculé lors d'une mise à jour groupée, comme lors d'un traitement
 * effectué via Data Loader.
 */
@isTest
private class testOrderNetAmountTrigger {

    /**
     * Vérifie que NetAmount__c est recalculé pour toutes les commandes
     * lors d'une même opération DML.
     */
    @isTest
    static void testNetAmountCalculatedForAllOrdersInBulkUpdate() {
        Account acc = TestDataFactory.createAccount('Client NetAmount');

        List<Order> orders = new List<Order>();

        // Création de plusieurs commandes afin de simuler une opération bulk.
        for (Integer i = 0; i < 5; i++) {
            orders.add(new Order(
                AccountId = acc.Id,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                ShipmentCost__c = 10
            ));
        }

        insert orders;

        Test.startTest();

        // Simule une mise à jour groupée façon Data Loader :
        // toutes les commandes sont modifiées lors d'une seule opération DML.
        for (Order o : orders) {
            o.ShipmentCost__c = 20;
        }

        update orders;

        Test.stopTest();

        List<Order> refreshedOrders = [
            SELECT NetAmount__c, TotalAmount, ShipmentCost__c
            FROM Order
            WHERE Id IN :orders
        ];

        System.assertEquals(
            5,
            refreshedOrders.size(),
            'Les 5 commandes doivent être récupérées après la mise à jour.'
        );

        // Vérifie que chaque commande du lot possède le montant net attendu.
        for (Order o : refreshedOrders) {
            System.assertEquals(
                o.TotalAmount - o.ShipmentCost__c,
                o.NetAmount__c,
                'Chaque commande du lot doit avoir son NetAmount__c recalculé, pas seulement la première.'
            );
        }
    }

    // Vérification CI/CD : validation de l'exécution complète des tests
    // et du bon fonctionnement du pipeline après modification du trigger.
}