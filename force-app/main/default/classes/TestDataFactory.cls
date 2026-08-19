/**
 * Classe utilitaire permettant de centraliser la création de données
 * de test réutilisables : comptes, produits, commandes et lignes
 * de commande.
 */
@isTest
public class TestDataFactory {

    /**
     * Crée et insère un compte avec le nom fourni.
     *
     * @param accountName Nom du compte à créer.
     * @return Le compte créé et inséré en base.
     */
    public static Account createAccount(String accountName) {
        Account acc = new Account(
            Name = accountName
        );

        insert acc;
        return acc;
    }

    /**
     * Crée un produit actif ainsi qu'une entrée dans le Pricebook standard.
     *
     * @param unitPrice Prix unitaire du produit.
     * @return Le PricebookEntry créé et associé au produit.
     */
    public static PricebookEntry createStandardPricebookEntry(
        Decimal unitPrice
    ) {
        Product2 product = new Product2(
            Name = 'Chemise Verte longue XYX',
            Family = 'Chemise'
        );

        insert product;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = product.Id,
            UnitPrice = unitPrice,
            IsActive = true
        );

        insert pbe;
        return pbe;
    }

    /**
     * Crée plusieurs commandes pour un compte donné, avec une ligne
     * de commande pour chacune.
     *
     * Les commandes sont d'abord créées en statut "Draft". Lorsque
     * shouldActivate vaut true, elles sont ensuite passées au statut
     * "Activated".
     *
     * Cette méthode permet notamment de générer un volume important
     * de commandes afin de tester le comportement bulkifié des classes Apex.
     *
     * @param accountId Compte auquel associer les commandes.
     * @param pricebookEntryId Produit utilisé pour les lignes de commande.
     * @param numberOfOrders Nombre de commandes à créer.
     * @param unitPrice Prix unitaire de chaque ligne.
     * @param quantity Quantité de produit pour chaque ligne.
     * @param shouldActivate Indique si les commandes doivent être activées.
     * @return Liste des commandes créées.
     */
    public static List<Order> createOrdersWithItems(
        Id accountId,
        Id pricebookEntryId,
        Integer numberOfOrders,
        Decimal unitPrice,
        Integer quantity,
        Boolean shouldActivate
    ) {
        List<Order> orders = new List<Order>();

        for (Integer i = 0; i < numberOfOrders; i++) {
            orders.add(new Order(
                AccountId = accountId,
                Pricebook2Id = Test.getStandardPricebookId(),
                Status = 'Draft',
                EffectiveDate = Date.today()
            ));
        }

        insert orders;

        List<OrderItem> items = new List<OrderItem>();

        for (Order o : orders) {
            items.add(new OrderItem(
                OrderId = o.Id,
                PricebookEntryId = pricebookEntryId,
                Quantity = quantity,
                UnitPrice = unitPrice
            ));
        }

        insert items;

        // Activation en une seule opération pour conserver un traitement bulkifié.
        if (shouldActivate) {
            for (Order o : orders) {
                o.Status = 'Activated';
            }

            update orders;
        }

        return orders;
    }

    // Vérification CI/CD : ce changement permet de valider l'exécution complète du pipeline.
}
