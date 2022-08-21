# EasyCharity
A simple app for collecting charity.
1. User can sign up and log in. (Used Firebase authentication)(Need email verification)
2. User can create a page asking charity. (Used Firebase database to save)
3. User can create more than one page for charity.
3. Other user can select that page and give charity by credit card. (Used Stripe to do the transaction)
4. A unique token will be received upon transaction completion, which only the charity giver knows he is, and can validate the total amount.

Used Tool: 
1. Firebase (For database)
2. Stripe (For money transaction)
3. Javascript (For server side code)
4. Heroku (For server hosting)
5. Coredata (For saving local data)

Some pic of the app:

First View

<img width="481" alt="1" src="https://user-images.githubusercontent.com/7429178/185783017-8d38dfe3-0ba4-4a8e-a629-00dc466173ae.png">

Dashboard

<img width="481" alt="3" src="https://user-images.githubusercontent.com/7429178/185783021-a07d3c4e-0e09-4c8b-9b70-873862e80faf.png">

Menu selected for either creating charity need or give charity.

<img width="481" alt="4" src="https://user-images.githubusercontent.com/7429178/185783024-ae49f626-289e-4416-bbc6-b3ed61516532.png">

Page that has details of why need charity.

<img width="481" alt="5" src="https://user-images.githubusercontent.com/7429178/185783025-ccf00a13-49dc-4d88-95ab-7f54ceda910a.png">

Page for giving charity amount. Page where stripe's paying checkout view is shown.

<img width="481" alt="6" src="https://user-images.githubusercontent.com/7429178/185783026-02f3b154-0335-4aa7-a4d8-878bf8fac3f7.png">

Page that shows the uniqueToken for each transaction and the amount, A user can find his tokenId if he gave charity and also the amount will be shown.

<img width="481" alt="7" src="https://user-images.githubusercontent.com/7429178/185783029-1695b1b5-ef26-4152-bb6e-29d29d170616.png">

List of charity item that can be given charity.

<img width="481" alt="8" src="https://user-images.githubusercontent.com/7429178/185783033-3baf21dd-6702-4748-ad60-e1ee1aab8158.png">


