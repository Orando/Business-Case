# Technical Architecture Overview
## Glovo Business Central Integration Solution

---

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           GLOVO ADMIN SYSTEM                                   │
│                         (Master Data Source)                                   │
└─────────────────────┬───────────────────────────────────────────────────────────┘
                      │
                      │ JSON Messages (REST API)
                      │ • Fiscal Data Messages
                      │ • Transaction Data Messages
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                      BUSINESS CENTRAL INTEGRATION LAYER                        │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   API Gateway   │  │ Message Queue   │  │  Log Processor  │                │
│  │   (Endpoints)   │  │   (Messages)    │  │    (Logging)    │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │  Integration    │  │   Dimension     │  │     Helper      │                │
│  │  Management     │  │  Correction     │  │   Functions     │                │
│  │   (Codeunit)    │  │   (Codeunit)    │  │   (Codeunit)    │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        BUSINESS CENTRAL DATABASE                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │    Customer     │  │     Vendor      │  │  Sales Invoice  │                │
│  │     Cards       │  │     Cards       │  │     Headers     │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │  Sales Lines    │  │   G/L Entries   │  │  Dimension      │                │
│  │ (Commission/Ads)│  │  (Corrections)  │  │   Corrections   │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           JOB QUEUE SYSTEM                                     │
├─────────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│  │   Nightly Job   │  │  Email Alerts   │  │  Manual Trigger │                │
│  │  (2:00 AM)      │  │ (Notifications) │  │   (On-Demand)   │                │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘                │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Architecture

### **Case 1: Fiscal Data Processing**

```
Admin System → JSON Message → Message Table → Integration Management
     ↓
Customer Creation/Update → Template Application → Vendor Creation (Optional)
     ↓
Success Logging → Integration Logs → Search Index Update
```

### **Case 2: Transaction Data Processing**

```
Admin System → JSON Message → Message Table → Integration Management
     ↓
Sales Header Creation → Commission Line → AdsGMO Line → GMV Integration
     ↓
VAT Validation → Invoice Generation → Success Logging
```

### **Case 3: Dimension Correction Flow**

```
Job Queue Trigger → G/L Entry Scan → Account Rule Check → Correction Application
     ↓
Dimension Update → Correction Logging → Email Notification → Status Update
```

---

## Component Architecture

### **Core Tables (5)**

| Table | Purpose | Key Features |
|-------|---------|--------------|
| **Business Case Setup** | Configuration management | API endpoints, templates, job queue settings |
| **Glovo Integration Logs** | Message tracking | Direction, status, error messages, search text |
| **Messages** | Message queue | Payload storage, processing status, timestamps |
| **Dimension Correction Rules** | Account rules | Include/exclude logic, dimension-specific rules |
| **Dimension Correction Log** | Audit trail | Correction history, user tracking, status |

### **Table Extensions (6)**

| Extension | Enhanced Functionality |
|-----------|----------------------|
| **Customer** | Actor External ID, Last Updated DateTime, Associated Vendor |
| **Vendor** | Customer association, template application |
| **G/L Account** | Correction rules, allow/deny flags |
| **Sales Line** | Campaign ID tracking, GMV integration |
| **G/L Entry** | Correction tracking, dimension history |
| **User Setup** | Role-based access control |

### **Codeunits (5)**

| Codeunit | Responsibility |
|----------|----------------|
| **Integration Management** | Message processing, customer/vendor creation, sales invoice generation |
| **Dimension Correction Mgt** | Automated corrections, job queue management, email notifications |
| **Log Processor** | Error tracking, success logging, search index management |
| **Helper** | Utility functions, template application, validation routines |
| **Events Handler** | System events, triggers, integration points |

---

## Security Architecture

### **Access Control**
- **Role-Based Permissions:** Granular access to setup and logs
- **API Key Management:** Secure endpoint authentication
- **User Tracking:** Complete audit trail with user identification
- **Data Classification:** Proper data handling and privacy compliance

### **Data Protection**
- **Encrypted Storage:** Sensitive data protection
- **Masked Display:** API keys hidden in UI
- **Audit Logging:** Complete change tracking
- **Backup Integration:** Standard BC backup procedures

---

## Performance Architecture

### **Optimization Strategies**
- **Batch Processing:** 100 records per commit cycle
- **Memory Management:** Efficient large dataset handling
- **Index Optimization:** Fast search and retrieval
- **Background Processing:** Non-blocking job queue execution

### **Scalability Features**
- **Modular Design:** Independent component scaling
- **Queue Management:** Message processing optimization
- **Resource Monitoring:** Performance tracking and alerts
- **Load Distribution:** Balanced processing across time windows

---

## Integration Architecture

### **API Integration**
```
External System ←→ REST API ←→ Message Queue ←→ Processing Engine ←→ BC Database
```

### **Message Format**
```json
{
  "messageType": "FiscalData|TransactionData",
  "timestamp": "2025-12-27T08:45:00Z",
  "actorExternalId": "12345",
  "data": {
    "legalName": "Company Name",
    "taxId": "IT12345678901",
    "address": {...},
    "commissionAmount": 100.00,
    "adsGMO": 50.00,
    "gmv": 1000.00,
    "campaignId": "CAMP123"
  }
}
```

### **Error Handling**
- **Validation Layer:** Input data validation
- **Retry Logic:** Automatic failure recovery
- **Error Classification:** Categorized error types
- **Notification System:** Proactive alert management

---

## Monitoring Architecture

### **Real-Time Monitoring**
- **Status Dashboard:** Live processing status
- **Error Tracking:** Immediate failure detection
- **Performance Metrics:** Processing time analysis
- **Resource Usage:** System resource monitoring

### **Alerting System**
- **Email Notifications:** Configurable alert recipients
- **Status Updates:** Real-time status changes
- **Threshold Monitoring:** Performance threshold alerts
- **Escalation Procedures:** Multi-level alert management

---

## Deployment Architecture

### **Environment Strategy**
- **Development:** Full feature development and testing
- **Staging:** Production-like testing environment
- **Production:** Live Glovo Italy environment
- **Disaster Recovery:** Backup and recovery procedures

### **Release Management**
- **Version Control:** AL source code management
- **Deployment Pipeline:** Automated deployment process
- **Rollback Procedures:** Safe deployment rollback
- **Change Management:** Controlled release process

---

## Future Architecture Considerations

### **Multi-Country Expansion**
- **Tenant Isolation:** Country-specific configurations
- **Shared Components:** Reusable core functionality
- **Localization Support:** Country-specific requirements
- **Central Management:** Multi-tenant administration

### **Advanced Features**
- **Machine Learning:** Predictive error detection
- **Advanced Analytics:** Business intelligence integration
- **Mobile Access:** Responsive management interface
- **API Expansion:** Additional integration endpoints

---