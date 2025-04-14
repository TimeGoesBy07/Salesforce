({
    handleNameChange: function (component, event, helper) {
        var nameInput = component.get("v.nameInput");
        console.log("Name is: " + nameInput);
    },

    handleDoBChange: function (component, event, helper) {
        var dobInput = component.get("v.dobInput");
        console.log("Name is: " + dobInput);
    },

    fetchClasses: function (component, event, helper) {
        console.log('function triggered')
        var action = component.get("c.getClasses");

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                component.set("v.classList", response.getReturnValue());
            } else {
                console.error("Failed to retrieve records");
            }
        });

        $A.enqueueAction(action);
    },

    handleClassChange: function (component, event, helper) {
        var classId = event.target.getAttribute("data-id");

        var classes = component.get("v.classList");
        var selectedClass = classes.find(function (cls) {
            return cls.Id === classId;
        });

        component.set("v.selectedAccount", selectedClass);
        component.set("v.searchKey", selectedClass.Name);
        component.set("v.accounts", []);
    },

    handleStatusChange: function (component, event, helper) {
        var statusInput = component.get("v.statusInput");
        console.log("Name is: " + statusInput);
    },

    handleGpaChange: function (component, event, helper) {
        var gpaInput = component.get("v.gpaInput");
        console.log("Name is: " + gpaInput);
    },

    handleCreditChange: function (component, event, helper) {
        var creditInput = component.get("v.creditInput");
        console.log("Name is: " + creditInput);
    },

    handleSubmit: function (component, event, helper) {
        var userInput = component.get("v.creditInput");
        alert("Submitted input: " + creditInput);
    }
})