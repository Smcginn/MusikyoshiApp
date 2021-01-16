import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import algoliasearch from 'algoliasearch';
import { DocumentSnapshot } from 'firebase-functions/lib/providers/firestore';

admin.initializeApp();
const env = functions.config();

const { CloudTasksClient } = require('@google-cloud/tasks');
const client = algoliasearch(env.algolia.appid, env.algolia.apikey);
const index = client.initIndex('users');

export const userOnCreate = functions.firestore.document('users/{uid}').onCreate(async (snapshot, context) => {
    await saveDocumentInAlgolia(snapshot);
});

export const userOnUpdate = functions.firestore.document('users/{uid}').onUpdate(async (change, context) => {
    await updateDocumentInAlgolia(change);
});

export const userOnDelete = functions.firestore.document('users/{uid}').onDelete(async (snapshot, context) => {
    await deleteDocumentFromAlgolia(snapshot);
});

export const challengeOnCreate = functions.firestore.document('challenges/{challengeId}').onCreate(async (snapshot, context) => {
    const data = snapshot.data()!

    const project = JSON.parse(process.env.FIREBASE_CONFIG!).projectId;
    const location = 'us-central1';
    const queue = 'challenges';

    const tasksClient = new CloudTasksClient();
    const queuePath: string = tasksClient.queuePath(project, location, queue);

    const url = `https://${location}-${project}.cloudfunctions.net/challengeEndCallback`;
    const docPath = snapshot.ref.path
    const payload = { docPath };
    const convertedPayload = JSON.stringify(payload);

    const task = {
        httpRequest: {
            httpMethod: 'POST',
            url,
            body: Buffer.from(convertedPayload).toString('base64'),
            headers: {
                'Content-Type': 'application/json'
            },
        },
        scheduleTime: {
            seconds: Date.now() / 1000 + 86400,
        }
    }

    try {
        const [response] = await tasksClient.createTask({queuePath, task});
        console.log(`Created task ${response.name}`);
        return response.name;
    } catch (error) {
        console.error(Error(error.message));
    }

})

export const challengeEndCallback = functions.https.onRequest(async (req, res) => {
    const payload = req.body;
    try {
        await admin.firestore().doc(payload.docPath).update({expired: true});
    } catch (error) {
        console.error(error);
        res.status(error.code).send(error);
    }
})

async function saveDocumentInAlgolia(snapshot: any) {
    if (snapshot.exists) {

        const data = snapshot.data();

        if (data && !data.isIncomplete) {

            const userId = snapshot.id;
            const username = data["username"];

            await index.saveObject({
                objectID: userId,
                username: username,
            });

        }

    }
}

async function updateDocumentInAlgolia(change: functions.Change<FirebaseFirestore.DocumentSnapshot>) {
    const docBeforeChange = change.before.data()
    const docAfterChange = change.after.data()
    if (docBeforeChange && docAfterChange) {
        await saveDocumentInAlgolia(change.after);
    }
}

async function deleteDocumentFromAlgolia(snapshot: FirebaseFirestore.DocumentSnapshot) {
    if (snapshot.exists) {
        const objectID = snapshot.id;
        await index.deleteObject(objectID);
    }
}