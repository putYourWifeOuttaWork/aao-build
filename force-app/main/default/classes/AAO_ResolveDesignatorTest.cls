/**
 * The resolver service's three outcomes, each tested for the thing it is there to stop.
 *
 * The acceptance rows are a23's dropped seven: a bare first name (Fatema), a title with no
 * name anywhere in the span (CFO), and the never-pick case that both can fall into.
 */
@IsTest
private class AAO_ResolveDesignatorTest {
    private static Id acctId;
    private static Id oppId;

    private static void world() {
        Account a = new Account(Name = 'Designator Test Co');
        insert a;
        acctId = a.Id;
        Opportunity o = new Opportunity(
            Name = 'Designator Test Deal', AccountId = a.Id,
            StageName = 'Stage 1', CloseDate = Date.today().addDays(30)
        );
        insert o;
        oppId = o.Id;
    }

    @IsTest
    static void aBareFirstNameLinksWhenItIsUnambiguousOnTheAccount() {
        world();
        Contact c = new Contact(FirstName = 'Fatema', LastName = 'Choudray', AccountId = acctId);
        insert c;

        AAO_ResolveDesignator.Outcome o = AAO_ResolveDesignator.resolve(
            'Fatema', AAO_ResolveDesignator.Kind.NAME, acctId, oppId
        );
        System.assertEquals('LINKED', o.verdict, o.toString());
        System.assertEquals(c.Id, o.contactId, o.toString());
    }

    @IsTest
    static void twoPeopleOfOneNameRefuseRatherThanPick() {
        world();
        insert new List<Contact>{
            new Contact(FirstName = 'Fatema', LastName = 'Choudray', AccountId = acctId),
            new Contact(FirstName = 'Fatema', LastName = 'Rahman', AccountId = acctId)
        };

        AAO_ResolveDesignator.Outcome o = AAO_ResolveDesignator.resolve(
            'Fatema', AAO_ResolveDesignator.Kind.NAME, acctId, oppId
        );
        System.assertEquals('AMBIGUOUS', o.verdict, o.toString());
        System.assertEquals(null, o.contactId, 'A guessed link is worse than no link.');
        System.assertEquals(2, o.candidates.size(), o.toString());
    }

    @IsTest
    static void aTitleLinksThroughTheSynonymList() {
        world();
        Contact c = new Contact(
            FirstName = 'Dana', LastName = 'Reyes', AccountId = acctId,
            Title = 'Chief Financial Officer'
        );
        insert c;

        // The span says "CFO". The Contact says "Chief Financial Officer". One title.
        AAO_ResolveDesignator.Outcome o = AAO_ResolveDesignator.resolve(
            'CFO', AAO_ResolveDesignator.Kind.TITLE, acctId, oppId
        );
        System.assertEquals('LINKED', o.verdict, o.toString());
        System.assertEquals(c.Id, o.contactId, o.toString());
    }

    @IsTest
    static void aTitleNobodyHoldsIsHeldAndNeverCreated() {
        world();
        insert new Contact(FirstName = 'Dana', LastName = 'Reyes', AccountId = acctId, Title = 'Buyer');

        Integer before = [SELECT COUNT() FROM Contact WHERE AccountId = :acctId];
        AAO_ResolveDesignator.Outcome o = AAO_ResolveDesignator.resolve(
            'CFO', AAO_ResolveDesignator.Kind.TITLE, acctId, oppId
        );
        System.assertEquals('ZERO', o.verdict, o.toString());
        System.assertEquals(
            before,
            [SELECT COUNT() FROM Contact WHERE AccountId = :acctId],
            'A TITLE CAN LINK BUT CAN NEVER CREATE. "CFO" has no LastName, and this service ' +
            'does not create at all.'
        );
        System.assert(o.because.contains('HELD'), o.because);
    }

    @IsTest
    static void twoPeopleHoldingOneTitleRefuseRatherThanPick() {
        world();
        insert new List<Contact>{
            new Contact(FirstName = 'Dana', LastName = 'Reyes', AccountId = acctId, Title = 'CFO'),
            new Contact(FirstName = 'Sam', LastName = 'Okafor', AccountId = acctId,
                Title = 'Chief Financial Officer')
        };

        AAO_ResolveDesignator.Outcome o = AAO_ResolveDesignator.resolve(
            'CFO', AAO_ResolveDesignator.Kind.TITLE, acctId, oppId
        );
        System.assertEquals('AMBIGUOUS', o.verdict, o.toString());
        System.assertEquals(2, o.candidates.size(),
            'The synonym list makes these two the same title, which is the point of it.');
    }

    @IsTest
    static void everyRungTriedIsJournalledWhetherItAnsweredOrNot() {
        world();
        AAO_ResolveDesignator.Outcome o = AAO_ResolveDesignator.resolve(
            'CFO', AAO_ResolveDesignator.Kind.TITLE, acctId, oppId
        );
        System.assert(
            o.rungsTried.size() >= 2,
            'A ladder that does not record the rungs it tried cannot be told from a loop: ' +
            o.rungsTried
        );
    }

    @IsTest
    static void noAccountScopeRefusesRatherThanSearchingEveryNamesake() {
        world();
        AAO_ResolveDesignator.Outcome o = AAO_ResolveDesignator.resolve(
            'Fatema', AAO_ResolveDesignator.Kind.NAME, null, oppId
        );
        System.assertEquals('ZERO', o.verdict, o.toString());
    }
}